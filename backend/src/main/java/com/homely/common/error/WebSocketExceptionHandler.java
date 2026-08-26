package com.homely.common.error;

import org.springframework.messaging.handler.annotation.MessageExceptionHandler;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.stereotype.Controller;

@Controller
public class WebSocketExceptionHandler {

    @MessageExceptionHandler
    @SendToUser("/queue/errors")
    public String handle(Exception ex) {
        return ex.getMessage();
    }
}
