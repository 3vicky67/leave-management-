CLASS zcl_clear_draft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_clear_draft IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Delete all records from the draft table
    DELETE FROM zleave_req_d.

    IF sy-subrc = 0.
      out->write( 'Draft data deleted from ZLEAVE_REQ_D. You can now activate your table.' ).
    ELSE.
      out->write( 'ZLEAVE_REQ_D is already empty or does not exist in the database.' ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
