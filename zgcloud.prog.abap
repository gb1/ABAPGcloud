*&---------------------------------------------------------------------*
*& Report ZGCLOUD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zgcloud.

include: <icon>.

class lcl_report definition.
*
  public section.

    data: instances type ztt_gcloud_instance,
          alv       type ref to cl_salv_table,
          api       type ref to zcl_gcloud.

    methods:
      get_data,
      generate_output raising cx_salv_msg cx_salv_not_found,
      on_event for event added_function of cl_salv_events.

endclass.                    "lcl_report DEFINITION

start-of-selection.
  data: lo_report type ref to lcl_report.
  create object lo_report.
  lo_report->get_data( ).
  lo_report->generate_output( ).
*
*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
class lcl_report implementation.
  method get_data.

    api = new zcl_gcloud( project = 'saphxe-158321' region = 'europe-west1-b' ).

    instances = api->list_instances( ).

    instances[ 2 ]-machine_type = 'n-highmem-32 (32 vCPU 208.00 GIB)'.

    loop at instances assigning field-symbol(<instance>).
      if <instance>-status = 'RUNNING'.
        <instance>-status = icon_green_light.
      else.
        <instance>-status = icon_red_light.
      endif.
    endloop.

  endmethod.                    "get_data

  method generate_output.

    cl_salv_table=>factory(
      importing
        r_salv_table = alv
      changing
        t_table      = instances ).

    alv->set_screen_status(
     pfstatus      = 'ZGCLOUD'
     report        = 'ZGCLOUD'
     set_functions = alv->c_functions_all ).

    alv->get_columns( )->set_optimize( abap_true ).
    alv->get_display_settings( )->set_list_header( 'Google Cloud Platform Console - ABAP Edition' ).

    data(header)  = new cl_salv_form_layout_grid( ).

*    header->create_flow( row = 1  column = 1 )->create_text( text = 'hello' ).
*    header->create_flow( row = 2  column = 1 )->create_text( text = 'hello' ).
*    header->create_flow( row = 3  column = 1 )->create_text( text = 'hello' ).

    header->create_flow( row = 1  column = 1 )->create_text( text = 'Select VM instances to start or stop').
    header->create_flow( row = 2  column = 1 )->create_text( text = 'Current Project: saphxe-158321').
    header->create_flow( row = 2  column = 2 )->create_text( text = 'Current Region: europe-west1-b').
    header->create_flow( row = 3  column = 1 )->create_text( text = 'https://console.cloud.google.com/compute/').


    alv->set_top_of_list( header ).

    alv->get_columns( )->get_column( 'NAME' )->set_long_text( 'Name' ).
    alv->get_columns( )->get_column( 'ZONE' )->set_long_text( 'Zone' ).
    alv->get_columns( )->get_column( 'MACHINE_TYPE' )->set_long_text( 'Type' ).
    alv->get_columns( )->get_column( 'INTERNAL_IP' )->set_long_text( 'Internal IP' ).
    alv->get_columns( )->get_column( 'EXTERNAL_IP' )->set_long_text( 'External IP' ).
    alv->get_columns( )->get_column( 'STATUS' )->set_long_text( 'Status' ).


    data: col type ref to cl_salv_column_table.

    col ?= alv->get_columns( )->get_column( 'STATUS' ).

    col->set_icon( abap_true ).

    set handler me->on_event for alv->get_event( ).

    alv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>multiple ).

    alv->display( ).

  endmethod.                    "generate_output

  method on_event.

    if sy-ucomm = 'REFRE'.
      get_data( ).
      alv->refresh( ).
      exit.
    endif.

    data(rows) = alv->get_selections( )->get_selected_rows( ).

    loop at rows into data(row).

      if sy-ucomm = 'START'.
        api->start_instance( instances[ row ]-name ).
        message 'Instance started' type 'I'.
      elseif sy-ucomm = 'STOP'.
        api->stop_instance( instances[ row ]-name ).
        message 'Instance stopped' type 'I'.
      endif.
    endloop.

    get_data( ).
    alv->refresh( ).

  endmethod.

endclass.
