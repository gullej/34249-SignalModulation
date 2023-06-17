
context transceiver_context is
    library osvvm_common ;  
        context osvvm_common.OsvvmCommonContext;

    library tranceiver_lib;
        use tranceiver_lib.tranceiver_component_pkg.all;

end context transceiver_context;