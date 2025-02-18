package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
)

const Port = "8080"

func buildFrontend() error {
	// run tailwindcss
	fmt.Println("Running TailwindCSS...")
	cmd := exec.Command("./frontend/css/tailwindcss", "-i", "./frontend/css/app.css", "-o", "./frontend/css/out.css", "--minify")
	if err := cmd.Run(); err != nil {
		return err
	}
	// build wasm
	fmt.Println("Rebuilding Wasm...")
	cmd = exec.Command("go", "build", "-o", "frontend/go/main.wasm", "./frontend/go")
	cmd.Env = append(os.Environ(), "GOOS=js", "GOARCH=wasm")
	return cmd.Run()
}

func main() {
	// initial frontend build
	if err := buildFrontend(); err != nil {
		log.Fatalf("Failed to build Wasm: %v", err)
	}

	// serve frontend files
	http.Handle("/frontend/", http.StripPrefix("/frontend/", http.FileServer(http.Dir("frontend"))))

	// build WASM on request and serve index.html
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if err := buildFrontend(); err != nil {
			http.Error(w, "Failed to build Wasm", http.StatusInternalServerError)
			return
		}
		http.ServeFile(w, r, "frontend/html/index.html")
	})

	fmt.Printf("Serving at http://localhost:%s\n", Port)
	if err := http.ListenAndServe(":"+Port, nil); err != nil {
		log.Fatal(err)
	}
}
