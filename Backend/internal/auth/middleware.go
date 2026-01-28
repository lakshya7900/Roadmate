package auth

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func GinRequireAuth(jwtSecret []byte) gin.HandlerFunc {
	return func(c *gin.Context) {
		h := c.GetHeader("Authorization")
		fmt.Println("Authorization header:", h)

		if h == "" || !strings.HasPrefix(h, "Bearer ") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "missing auth"})
			return
		}

		token := strings.TrimPrefix(h, "Bearer ")
		fmt.Println("Token:", len(token))

		claims, err := ParseToken(jwtSecret, token)
		if err != nil {
            fmt.Println("ParseToken error:", err)
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
			return
		}

		c.Set("uid", claims.UserID)
		c.Set("usr", claims.Username)
		c.Next()
	}
}