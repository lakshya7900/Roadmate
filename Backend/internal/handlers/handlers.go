package handlers

import (
	"context"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Handler struct {
	DB        *pgxpool.Pool
	JWTSecret []byte
}

func New(db *pgxpool.Pool, jwtSecret []byte) *Handler {
	return &Handler{DB: db, JWTSecret: jwtSecret}
}

func contextTimeout(c *gin.Context, d time.Duration) (context.Context, context.CancelFunc) {
	return context.WithTimeout(c.Request.Context(), d)
}