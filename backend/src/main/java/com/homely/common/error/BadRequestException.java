package com.homely.common.error;

public class BadRequestException extends BusinessException {
    public BadRequestException(String message) {
        super(message);
    }
}
