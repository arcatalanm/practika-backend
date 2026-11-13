package com.practika.ms_academic;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@org.springframework.cloud.openfeign.EnableFeignClients
@SpringBootApplication
public class MsAcademicApplication {

	public static void main(String[] args) {
		SpringApplication.run(MsAcademicApplication.class, args);
	}

}
