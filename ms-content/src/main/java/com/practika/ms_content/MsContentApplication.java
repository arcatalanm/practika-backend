package com.practika.ms_content;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients(basePackages = "com.practika.ms_content.client")
public class MsContentApplication {

	public static void main(String[] args) {
		SpringApplication.run(MsContentApplication.class, args);
	}

}
