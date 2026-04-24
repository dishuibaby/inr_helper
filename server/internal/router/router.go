package router

import (
	"github.com/gin-gonic/gin"
	"warfarin-inr-demo/server/internal/handler"
	"warfarin-inr-demo/server/internal/repository/memory"
	"warfarin-inr-demo/server/internal/service"
)

func New() *gin.Engine {
	gin.SetMode(gin.ReleaseMode)
	repo := memory.NewRepository()
	svc := service.New(repo)
	h := handler.New(svc)

	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())
	r.GET("/healthz", h.Health)

	v1 := r.Group("/api/v1")
	v1.GET("/home/summary", h.HomeSummary)
	v1.POST("/medication/records", h.CreateMedicationRecord)
	v1.GET("/inr/records", h.ListINRRecords)
	v1.POST("/inr/records", h.CreateINRRecord)
	v1.GET("/settings", h.GetSettings)
	v1.PUT("/settings", h.UpdateSettings)

	return r
}
