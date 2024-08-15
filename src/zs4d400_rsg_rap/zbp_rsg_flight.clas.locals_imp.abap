CLASS lhc_zrsg_r_flight DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Flight
        RESULT result,
      validatePrice FOR VALIDATE ON SAVE
        IMPORTING keys FOR Flight~validatePrice,
      validatecurrencycode FOR VALIDATE ON SAVE
        IMPORTING keys FOR flight~validatecurrencycode.
ENDCLASS.

CLASS lhc_zrsg_r_flight IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD validatePrice.


    DATA failed_record   LIKE LINE OF failed-flight.
    DATA reported_record LIKE LINE OF reported-flight.

    READ ENTITIES OF zrsg_r_flight IN LOCAL MODE
         ENTITY flight
         FIELDS ( price )
         WITH CORRESPONDING #( keys )
         RESULT DATA(flights).

    LOOP AT flights INTO DATA(flight).
      IF flight-price <= 0.

        failed_record-%tky = flight-%tky.
        APPEND failed_record TO failed-flight.

        reported_record-%tky = flight-%tky.

        reported_record-%msg =
           new_message(
             id       = 'ZRSG_MESS'
             number   = '101'
             severity = if_abap_behv_message=>severity-error
           ).
        APPEND reported_record TO reported-flight.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatecurrencycode.

    DATA failed_record   LIKE LINE OF failed-flight.
    DATA reported_record LIKE LINE OF reported-flight.
    DATA exists TYPE abap_bool.

    READ ENTITIES OF zrsg_r_flight IN LOCAL MODE
         ENTITY flight
         FIELDS ( currencycode )
         WITH CORRESPONDING #( keys )
         RESULT DATA(flights).

    LOOP AT flights INTO DATA(flight).

      exists = abap_false.

      SELECT SINGLE FROM i_currency
            FIELDS @abap_true
            WHERE currency = @flight-currencycode
            INTO @exists.

      IF  exists = abap_false.   " the currency code is not valid

        failed_record-%tky = flight-%tky.
        APPEND failed_record TO failed-flight.

        reported_record-%tky = flight-%tky.

        reported_record-%msg =
          new_message(
            id       = 'ZRSG_MESS'
            number   = '102'
            severity = if_abap_behv_message=>severity-error
            v1       = flight-currencycode
          ).

        APPEND reported_record TO reported-flight.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
