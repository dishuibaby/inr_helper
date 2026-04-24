package main

import "warfarin-inr-demo/server/internal/router"

func main() {
	r := router.New()
	if err := r.Run(":8080"); err != nil {
		panic(err)
	}
}
