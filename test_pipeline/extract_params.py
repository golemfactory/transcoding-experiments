import re


## ======================= ##
##
def find_parameters( file_name ):
    
    regex = r'\[([^\[\]]+)\]'
    return re.findall( regex, file_name )


## ======================= ##
##
def extract_params( file_name ):
    
    params_dict = dict()
    
    params = find_parameters( file_name )
    for param in params:

        if param.find( "=" ) >= 0:
            
            ( name, value ) = param.split( "=" )
            params_dict[ name ] = value
        else:
            params_dict[ name ] = True
    
    return params_dict

    