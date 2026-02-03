package handlers

import (
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// ========= Task DTOs (responses) =========
type Task struct {
	ID string					`json:"id"`
	ProjectID string			`json:"project_id"`
	Title string				`json:"title"`
	Details string				`json:"details"`
	Status string				`json:"status"`
	AssigneeID *string			`json:"assignee_id"`
	AssigneeUsername *string	`json:"assignee_username"`
	Difficulty int				`json:"difficulty"`
	SortIndex int				`json:"sort_index"`
	CreatedAt string			`json:"created_at"`
}

// ========= Requests =========
type createTaskReq struct {
	Title string		`json:"title"`
	Details string		`json:"details"`
	Status string		`json:"status"`
	AssigneeID *string	`json:"assignee_id"`
	Difficulty int		`json:"difficulty"`
	SortIndex *int		`json:"sort_index"`
}

func (h *Handler) AddTask(c *gin.Context) {
	uidAny, ok := c.Get("uid")
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "missing auth"})
		return
	}
	uid, ok := uidAny.(string)
	if !ok || uid == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "bad auth"})
		return
	}

	projectIDStr := strings.TrimSpace(c.Param("id"))
	projectID, projIdErr := uuid.Parse(projectIDStr)
	if projIdErr != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid project id"})
		return
	}

	var req createTaskReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "bad json"})
		return
	}

	title := strings.TrimSpace(req.Title)
	if title == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing title"})
		return
	}

	details := strings.TrimSpace(req.Details)

	status := strings.TrimSpace(req.Status)
	if status == "" {
		status = "backlog"
	}
	if !isValidTaskStatus(status) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid status"})
		return
	}

	diff := req.Difficulty
	if diff == 0 {
		diff = 2
	}
	if diff < 1 || diff > 5 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid difficulty"})
		return
	}

	// Normalize assignee: treat missing/blank as NULL (unassigned)
	var assignee any = nil
	if req.AssigneeID != nil {
		a := strings.TrimSpace(*req.AssigneeID)
		if a != "" {
			assignee = a // UUID string; postgres will cast to uuid
		}
	}


	ctx, cancel := contextTimeout(c, 5*time.Second)
	defer cancel()

	var allowed bool
	if err := h.DB.QueryRow(ctx, `
		select exists (
			select 1
			from projects_members
			where project_id = $1
			and user_id::text = $2
		)
	`, projectID, uid).Scan(&allowed); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		return
	}
	if !allowed {
		c.JSON(http.StatusForbidden, gin.H{"error": "not a project member"})
		return
	}

	var out Task
	var createdAt time.Time

	var sortIndex *int
	if req.SortIndex != nil {
		si := *req.SortIndex
		if si < 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid sort_index"})
			return
		}
		sortIndex = &si
	}


	err := h.DB.QueryRow(ctx, `
	with desired as (
		select coalesce(
			$7::int,
			(select coalesce(max(sort_index), -1) + 1
			from tasks
			where project_id = $1 and status = $4)
		) as idx
	), shifted as (
		update tasks
		set sort_index = sort_index + 1
		where project_id = $1
			and status = $4
			and $7::int is not null
			and sort_index >= (select idx from desired)
	), inserted as (
		insert into tasks (project_id, title, details, status, assignee_id, difficulty, sort_index)
		values ($1, $2, $3, $4, $5, $6, (select idx from desired))
		returning *
	)
	select inserted.id::text,
		inserted.project_id::text,
		inserted.title,
		inserted.details,
		inserted.status,
		inserted.assignee_id::text,
		u.username,
		inserted.difficulty,
		inserted.sort_index,
		inserted.created_at
	from inserted
	left join users u on u.id = inserted.assignee_id
	`, projectID, title, details, status, assignee, diff, sortIndex).
	Scan(
		&out.ID,
		&out.ProjectID,
		&out.Title,
		&out.Details,
		&out.Status,
		&out.AssigneeID,
		&out.AssigneeUsername,
		&out.Difficulty,
		&out.SortIndex,
		&createdAt,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "server error"})
		return
	}

	out.CreatedAt = createdAt.UTC().Format(time.RFC3339)
	c.JSON(http.StatusOK, out)
}

func isValidTaskStatus(s string) bool {
	switch s {
	case "backlog", "inProgress", "blocked", "done":
		return true
	default:
		return false
	}
}

func nullableString(p *string) string {
	if p == nil {
		return ""
	}
	return strings.TrimSpace(*p)
}