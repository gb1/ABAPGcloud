class tests definition deferred.
class zcl_gcloud definition local friends tests.

class tests definition for testing
  duration short
  risk level harmless
.
  private section.
    data:
      f_cut type ref to zcl_gcloud.  "class under test

    methods: setup.
    methods: list_instances for testing.
    methods: run_gcloud_command for testing.
    methods: set_region for testing.
    methods: set_project for testing.
    methods: start_instance for testing.
    methods: stop_instance for testing.
endclass.       "tests


class tests implementation.


  method setup.
    f_cut = new zcl_gcloud( project = 'saphxe-158321' region = 'europe-west1-b' ).
  endmethod.



  method list_instances.
    data(instances) = f_cut->list_instances(  ).

    cl_abap_unit_assert=>assert_not_initial(
      act = instances
      msg = 'test we can list the instances in the project' ).

  endmethod.


  method run_gcloud_command.

    data command type btcxpgpar value '--version'.

    data(results) = f_cut->run_gcloud_command( command ).

    cl_abap_unit_assert=>assert_char_cp(
      act = results[ 1 ]
      exp = '*Google Cloud SDK*'
      msg = 'test gcloud command is executing ok, it should print the version' ).


  endmethod.


  method set_region.
    f_cut->set_region( 'europe-west1-b' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'europe-west1-b'
      act = f_cut->region
      msg = 'test setting the region' ).

    f_cut->set_region( 'europe-west1-d' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'europe-west1-d'
      act = f_cut->region
      msg = 'test changing the region' ).

  endmethod.

  method set_project.
    f_cut->set_project( 'abap' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'abap'
      act = f_cut->project
      msg = 'test setting the project' ).

    f_cut->set_project( 'saphxe-158321' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'saphxe-158321'
      act = f_cut->project
      msg = 'test changing the project' ).

  endmethod.

  method start_instance.
    f_cut->set_region( 'europe-west1-b' ).

    f_cut->start_instance( 'ubuntu-1604-lts' ).
  endmethod.

  method stop_instance.
    f_cut->stop_instance( 'ubuntu-1604-lts' ).
  endmethod.

endclass.
