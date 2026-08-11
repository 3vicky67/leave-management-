CLASS lhc_ziemployee DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Employee RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Employee RESULT result.

ENDCLASS.

CLASS lhc_ziemployee IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " This allows the Edit and Delete buttons to work
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<auth_result>).
      <auth_result>-%tky = <key>-%tky.

      IF requested_authorizations-%update = if_abap_behv=>mk-on.
        <auth_result>-%update = if_abap_behv=>auth-allowed.
      ENDIF.

      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        <auth_result>-%delete = if_abap_behv=>auth-allowed.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
    " ---> CRITICAL: This allows the Fiori Create button to appear <---
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
