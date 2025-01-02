global class RestSchema {

    global enum RestStatus {
        OK,
        ERROR
    }
    
    global class RestMessageResponse{
        global String message;
        global String status;

        global RestMessageResponse(String message, RestStatus restStatus) {
            this.message = message;
            this.status = restStatus.name();
        }
    }
}