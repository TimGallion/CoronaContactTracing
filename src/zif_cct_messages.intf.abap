INTERFACE zif_cct_messages
  PUBLIC .

  CONSTANTS: msgid TYPE symsgid VALUE 'ZCCT_MESSAGES',
             BEGIN OF msgno,
               employee_not_found TYPE symsgno VALUE '001',
               testcase_not_found TYPE symsgno VALUE '002',
             END OF msgno.

ENDINTERFACE.
