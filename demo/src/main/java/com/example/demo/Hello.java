package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Hello {

    @GetMapping("/")  // root path
    public String home() {
        return "Hello, Barq!";
    }

    @GetMapping("/ping")  // extra endpoint
    public String ping() {
        return "pong";
    }
}
