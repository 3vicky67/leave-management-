CLASS lhc_Leave DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Leave RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Leave RESULT result.

    METHODS approveLeave FOR MODIFY
      IMPORTING keys FOR ACTION Leave~approveLeave RESULT result.

    METHODS rejectLeave FOR MODIFY
      IMPORTING keys FOR ACTION Leave~rejectLeave RESULT result.

    METHODS calculateDuration FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Leave~calculateDuration.

    METHODS setDefaultStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Leave~setDefaultStatus.

    " ---> CHANGED: Replaced checkLeaveBalance with autoApproveReject <---
    METHODS autoApproveReject FOR DETERMINE ON SAVE
      IMPORTING keys FOR Leave~autoApproveReject.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Leave~validateDates.
ENDCLASS.

CLASS lhc_Leave IMPLEMENTATION.

  METHOD get_instance_authorizations.
    DATA lt_requests TYPE TABLE FOR READ RESULT ZI_LEAVE.
    DATA ls_req LIKE LINE OF lt_requests.

    READ ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT lt_requests.

    LOOP AT lt_requests INTO ls_req.
      APPEND VALUE #( %tky = ls_req-%tky
                      %update              = if_abap_behv=>auth-allowed
                      %delete              = if_abap_behv=>auth-allowed
                      %action-Edit         = if_abap_behv=>auth-allowed
                      %action-approveLeave = if_abap_behv=>auth-allowed
                      %action-rejectLeave  = if_abap_behv=>auth-allowed
                    ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    DATA lt_leave_requests TYPE TABLE FOR READ RESULT ZI_LEAVE.
    DATA ls_req LIKE LINE OF lt_leave_requests.

    READ ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT lt_leave_requests
      FAILED failed.

    LOOP AT lt_leave_requests INTO ls_req.
      APPEND VALUE #( %tky = ls_req-%tky
                      " Enable Approve button if it's Pending OR currently Rejected
                      %action-approveLeave = COND #( WHEN ls_req-Status = 'P' OR ls_req-Status = 'R'
                                                    THEN if_abap_behv=>fc-o-enabled
                                                    ELSE if_abap_behv=>fc-o-disabled )

                      " Enable Reject button if it's Pending OR currently Approved
                      %action-rejectLeave  = COND #( WHEN ls_req-Status = 'P' OR ls_req-Status = 'A'
                                                    THEN if_abap_behv=>fc-o-enabled
                                                    ELSE if_abap_behv=>fc-o-disabled )
                    ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD approveLeave.
    DATA lt_update TYPE TABLE FOR UPDATE ZI_LEAVE.
    DATA lt_leave_requests TYPE TABLE FOR READ RESULT ZI_LEAVE.
    DATA ls_req LIKE LINE OF lt_leave_requests.

    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky = ls_key-%tky Status = 'A' ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave
      UPDATE FIELDS ( Status ) WITH lt_update
      FAILED failed REPORTED reported.

    READ ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_leave_requests.

    LOOP AT lt_leave_requests INTO ls_req.
      APPEND VALUE #( %tky = ls_req-%tky %param = ls_req ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD rejectLeave.
    DATA lt_update TYPE TABLE FOR UPDATE ZI_LEAVE.
    DATA lt_leave_requests TYPE TABLE FOR READ RESULT ZI_LEAVE.
    DATA ls_req LIKE LINE OF lt_leave_requests.

    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky = ls_key-%tky Status = 'R' ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave
      UPDATE FIELDS ( Status ) WITH lt_update
      FAILED failed REPORTED reported.

    READ ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_leave_requests.

    LOOP AT lt_leave_requests INTO ls_req.
      APPEND VALUE #( %tky = ls_req-%tky %param = ls_req ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculateDuration.
    DATA lt_requests TYPE TABLE FOR READ RESULT ZI_LEAVE.
    DATA ls_request LIKE LINE OF lt_requests.
    DATA lt_update TYPE TABLE FOR UPDATE ZI_LEAVE.

    READ ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave
      FIELDS ( StartDate EndDate ) WITH CORRESPONDING #( keys )
      RESULT lt_requests.

    LOOP AT lt_requests INTO ls_request WHERE StartDate IS NOT INITIAL AND EndDate IS NOT INITIAL.
      DATA(lv_days) = ls_request-EndDate - ls_request-StartDate + 1.
      APPEND VALUE #( %tky = ls_request-%tky TotalDays = lv_days ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_LEAVE IN LOCAL MODE
        ENTITY Leave UPDATE FIELDS ( TotalDays ) WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD setDefaultStatus.
    DATA lt_requests TYPE TABLE FOR READ RESULT ZI_LEAVE.
    DATA ls_req LIKE LINE OF lt_requests.
    DATA lt_update TYPE TABLE FOR UPDATE ZI_LEAVE.

    READ ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT lt_requests.

    LOOP AT lt_requests INTO ls_req.
      IF ls_req-Status IS INITIAL.
        APPEND VALUE #( %tky = ls_req-%tky Status = 'P' ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_LEAVE IN LOCAL MODE
        ENTITY Leave UPDATE FIELDS ( Status ) WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD validateDates.
    DATA lt_requests TYPE TABLE FOR READ RESULT ZI_LEAVE.
    DATA ls_request LIKE LINE OF lt_requests.

    READ ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave
      FIELDS ( StartDate EndDate ) WITH CORRESPONDING #( keys )
      RESULT lt_requests.

    LOOP AT lt_requests INTO ls_request.
      IF ls_request-EndDate < ls_request-StartDate.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-leave.
        APPEND VALUE #( %tky = ls_request-%tky
                        %msg = new_message( id       = 'ZLEAVE_MSG'
                                            number   = '001'
                                            severity = if_abap_behv_message=>severity-error
                                            v1       = 'End Date cannot be before Start Date' )
                      ) TO reported-leave.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " ---------------------------------------------------------------------
  " ---> NEW DETERMINATION: Automatically Approve or Reject Leave <---
  " ---------------------------------------------------------------------
  METHOD autoApproveReject.
    DATA lt_requests TYPE TABLE FOR READ RESULT ZI_LEAVE.
    DATA ls_request LIKE LINE OF lt_requests.
    DATA lt_update TYPE TABLE FOR UPDATE ZI_LEAVE.

    " Read Employee ID and Calculated Total Days from transactional buffer
    READ ENTITIES OF ZI_LEAVE IN LOCAL MODE
      ENTITY Leave
      FIELDS ( EmpId TotalDays ) WITH CORRESPONDING #( keys )
      RESULT lt_requests.

    LOOP AT lt_requests INTO ls_request.
      " Get current leave balance from master database
      SELECT SINGLE leave_balance
        FROM zemployee_db
        WHERE emp_id = @ls_request-EmpId
        INTO @DATA(lv_balance).

      IF sy-subrc = 0.
        " Automatically assign status based on remaining balance
        IF ls_request-TotalDays <= lv_balance.
          APPEND VALUE #( %tky = ls_request-%tky Status = 'A' ) TO lt_update.
        ELSE.
          APPEND VALUE #( %tky = ls_request-%tky Status = 'R' ) TO lt_update.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " Apply the status changes directly before saving
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_LEAVE IN LOCAL MODE
        ENTITY Leave
        UPDATE FIELDS ( Status ) WITH lt_update.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
