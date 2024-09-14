return {
    DrawMarker = true, -- if you don't want marker put here false
    EnableFadeOut = false, -- if you don't want screen fading disable this

    Elevators = {
        [1] = {
            name = 'Ambulance',
            coords = {
                vec3(296.04, -1447.08, 29.96),  -- 1st floor
                vec3(334.68, -1432.24, 46.52),  -- 2nd floor
                vec3(367.8, -1393.6, 76.16)     -- 3rd floor etc
            },
            jobs = false,
            restrictedFloors = {
                [2] = {jobs = {'ambulance'}} -- Only ambulance can access 2nd floor
            },
            floorNames = { '1. patro', '2. patro', '3. patro' }
        },

        [2] = {
            name = 'Maze Bank',
            coords = {
                vec3(-69.96, -799.96, 44.24),   -- 1st floor  
                vec3(-75.72, -815.12, 326.16)   -- 2nd floor   
            },
            jobs = false,
            restrictedFloors = {
                [1] = {jobs = {'police'}} -- Police cannot access 1st floor
            },
            floorNames = { '1. patro', '2. patro' }
        },
    },

    translations = {
        confirm = "Potvrdit",
        cancel = "Zrušit"
    }
}
