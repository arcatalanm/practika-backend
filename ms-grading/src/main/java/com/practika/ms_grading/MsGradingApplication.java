package com.practika.ms_grading;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients(basePackages = "com.practika.ms_grading.client")
public class MsGradingApplication {

	public static void main(String[] args) {
		SpringApplication.run(MsGradingApplication.class, args);
	}

}
