class zcl_gcloud definition
  public
  final
  create public .

  public section.

    methods constructor
      importing
        !project type string optional
        !region  type string optional .
    methods set_region
      importing
        !region type string .
    methods list_instances
      returning
        value(instances) type ztt_gcloud_instance .
    methods start_instance importing !instance type string.
    methods stop_instance importing !instance type string.
  protected section.
  private section.

    data region type string .
    data project type string .

    methods run_gcloud_command
      importing
        !command       type btcxpgpar
      returning
        value(results) type table_of_strings .
    methods set_project
      importing
        !project type string .
ENDCLASS.



CLASS ZCL_GCLOUD IMPLEMENTATION.


  method constructor.

    if project is not initial.
      me->project = project.
    endif.

    if project is not initial.
      me->region = region.
    endif.

  endmethod.


  method list_instances.

    data: command type btcxpgpar.

    command = 'compute instances list'.

    data(results) = run_gcloud_command( command ).

    loop at results into data(result).
      if sy-tabix = 1. "headers
        continue.
      endif.

      replace all occurrences of regex '\s{2,}' in result with cl_abap_char_utilities=>horizontal_tab.

      split result at cl_abap_char_utilities=>horizontal_tab into:
        data(name) data(zone) data(machine_type) data(internal_ip) data(external_ip) data(status),
        table data(bits).

      data: instance type zty_gcloud_instance.
      instance-name = name.
      instance-zone = zone.
      instance-machine_type = machine_type.
      instance-internal_ip = internal_ip.
      instance-external_ip = external_ip.
      instance-status = status.
      append instance to instances.
    endloop.

  endmethod.


  method run_gcloud_command.

    data: stdout type table of btcxpm.

    call function 'SXPG_CALL_SYSTEM'
      exporting
        commandname                = 'ZGCLOUD'
        additional_parameters      = command
      tables
        exec_protocol              = stdout
      exceptions
        no_permission              = 1
        command_not_found          = 2
        parameters_too_long        = 3
        security_risk              = 4
        wrong_check_call_interface = 5
        program_start_error        = 6
        program_termination_error  = 7
        x_error                    = 8
        parameter_expected         = 9
        too_many_parameters        = 10
        illegal_command            = 11
        others                     = 12.
    if sy-subrc <> 0.
* Implement suitable error handling here
    endif.

    loop at stdout into data(line).
      append line-message to results.
    endloop.

  endmethod.


  method set_project.

    me->project = project.

  endmethod.


  method set_region.

    me->region = region.

  endmethod.


  method start_instance.
    assert me->region is not initial.
    data(results) = run_gcloud_command( |compute instances start | && instance && | --zone | && me->region ).
  endmethod.


  method stop_instance.
    assert me->region is not initial.
    data(results) = run_gcloud_command( |compute instances stop | && instance && | --zone | && me->region ).
  endmethod.
ENDCLASS.
