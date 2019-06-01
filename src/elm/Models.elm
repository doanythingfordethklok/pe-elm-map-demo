module Models exposing (Address, Description, Incident)


type alias Incident =
    { address : Address
    , description : Description
    }


type alias Description =
    { incident_number : String
    , cat : String
    , sub_cat : String
    }


type alias Address =
    { address_line1 : String
    , city : String
    , state : String
    , common_place_name : String
    , latitude : Float
    , longitude : Float
    }
