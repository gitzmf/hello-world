package com.example.helloworld.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author zmf
 * @version 1.0
 * @ClassName HelloController
 * @Description: 测试接口
 * @date 2020/4/3 16:04
 */
@RestController
public class HelloController {

    @GetMapping("/hello/{name}")
    public String sayHello(@PathVariable("name") String name) {
        return "hello " + name + " !";
    }
}
