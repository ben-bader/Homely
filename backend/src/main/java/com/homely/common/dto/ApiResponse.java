package com.homely.common.dto;

public class ApiResponse<T> {
    private T data;
    private boolean success;
    private String message;

    public ApiResponse(T data) {
        this.data = data;
        this.success = true;
    }
}