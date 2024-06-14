package main

import "github.com/gin-gonic/gin"

func main() {
	r := gin.Default()
	r.GET("/echo", func(c *gin.Context) {
		message := c.Query("message")
		c.JSON(200, gin.H{
			"message": "You said: " + message,
		})
	})
	r.Run(":8080")
}
