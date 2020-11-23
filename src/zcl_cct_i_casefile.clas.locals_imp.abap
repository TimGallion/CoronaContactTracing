*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lhc_casefile DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateHealthDepEm FOR VALIDATE ON SAVE
      IMPORTING keys FOR casefile~validateHealthDepEm.

    METHODS validateTestCase FOR VALIDATE ON SAVE
      IMPORTING keys FOR casefile~validateTestCase.

ENDCLASS.

CLASS lhc_casefile IMPLEMENTATION.

  METHOD validateHealthDepEm.

    READ ENTITY zcct_i_casefile FROM VALUE #(
        FOR <root_key> IN keys ( %key-casefile_id   = <root_key>-casefile_id
                                 %control           = VALUE #( healthdepem_id = if_abap_behv=>mk-on ) ) )
        RESULT DATA(lt_casefile).

    DATA lt_healthdepem TYPE SORTED TABLE OF zcct_i_healthdepem WITH UNIQUE KEY emplyee_id.

    " Optimization of DB select: extract distinct non-initial customer IDs
    lt_healthdepem = CORRESPONDING #( lt_healthdepem DISCARDING DUPLICATES MAPPING emplyee_id = emplyee_id EXCEPT * ).
    DELETE lt_healthdepem WHERE emplyee_id IS INITIAL.
    CHECK lt_healthdepem IS NOT INITIAL.

    " Check if customer ID exist
    SELECT FROM zcct_i_healthdepem FIELDS emplyee_id
      FOR ALL ENTRIES IN @lt_healthdepem
      WHERE emplyee_id = @lt_healthdepem-emplyee_id
      INTO TABLE @DATA(lt_employee_db).

    " Raise msg for non existing customer id
    LOOP AT lt_casefile INTO DATA(ls_casefile).
      IF ls_casefile-healthdepem_id IS NOT INITIAL AND NOT line_exists( lt_employee_db[ emplyee_id = ls_casefile-healthdepem_id ] ).
        APPEND VALUE #(  casefile_id = ls_casefile-casefile_id ) TO failed-casefile.
        APPEND VALUE #(  casefile_id = ls_casefile-casefile_id
                         %msg      = new_message( id       = zif_cct_messages=>msgid
                                                  number   = zif_cct_messages=>msgno-employee_not_found
                                                  v1       = ls_casefile-healthdepem_id
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-healthdepem_id = if_abap_behv=>mk-on ) TO reported-casefile.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateTestCase.

  READ ENTITY zcct_i_casefile FROM VALUE #(
        FOR <root_key> IN keys ( %key-casefile_id   = <root_key>-casefile_id
                                 %control           = VALUE #( testcase_id = if_abap_behv=>mk-on ) ) )
        RESULT DATA(lt_casefile).

    DATA lt_testcase TYPE SORTED TABLE OF zcct_i_testcase WITH UNIQUE KEY testid.

    " Optimization of DB select: extract distinct non-initial customer IDs
    lt_testcase = CORRESPONDING #( lt_testcase DISCARDING DUPLICATES MAPPING testid = testid EXCEPT * ).
    DELETE lt_testcase WHERE testid IS INITIAL.
    CHECK lt_testcase IS NOT INITIAL.

    " Check if customer ID exist
    SELECT FROM zcct_i_testcase FIELDS testid
      FOR ALL ENTRIES IN @lt_testcase
      WHERE testid = @lt_testcase-testid
      INTO TABLE @DATA(lt_testcase_db).

    " Raise msg for non existing customer id
    LOOP AT lt_casefile INTO DATA(ls_casefile).
      IF ls_casefile-testcase_id IS NOT INITIAL AND NOT line_exists( lt_testcase_db[ testid = ls_casefile-testcase_id ] ).
        APPEND VALUE #(  casefile_id = ls_casefile-casefile_id ) TO failed-casefile.
        APPEND VALUE #(  casefile_id = ls_casefile-casefile_id
                         %msg      = new_message( id       = zif_cct_messages=>msgid
                                                  number   = zif_cct_messages=>msgno-testcase_not_found
                                                  v1       = ls_casefile-testcase_id
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-testcase_id = if_abap_behv=>mk-on ) TO reported-casefile.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
