module Models exposing (Address, Description, Incident, Parcel, Pin, Point, Viewport, Weather)

import Time exposing (Posix)


type alias Incident =
    { address : Address
    , description : Description
    }


type alias Description =
    { incident_number : String
    , cat : String
    , sub_cat : String
    , date : Posix
    , comments : String
    }


type alias Address =
    { address_line1 : String
    , city : String
    , state : String
    , common_place_name : String
    , latitude : Float
    , longitude : Float
    }


type alias Pin =
    { position : Point
    , id : String
    }


type alias Point =
    { lat : Float
    , lng : Float
    }


type alias Viewport =
    { center : Point
    , zoom : Int
    }


type alias Weather =
    { temperature : Float
    , summary : String
    }


type alias Parcel =
    { owner : String
    , address : String
    , land_value : Float
    , land_sqft : Float
    }
