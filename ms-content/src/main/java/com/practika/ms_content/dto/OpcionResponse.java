package com.practika.ms_content.dto;
import com.fasterxml.jackson.annotation.JsonInclude;
@JsonInclude(JsonInclude.Include.NON_NULL)
public record OpcionResponse(Integer id,String texto,Boolean esCorrecta) {}
