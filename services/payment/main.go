package main

import (
	"context"
	"fmt"
	"os/signal"
	"syscall"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	fmt.Println("Payment service is running...")
	<-ctx.Done()
	fmt.Println("Payment service is shut down...")
}
