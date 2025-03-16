Config = {}

Config.Target = 'ox' -- 'ox' or 'qb'
Config.Units = "mph" -- "kmh" or "mph"

Config.TestPrice = 500
Config.PassThreshold = 70 -- %

Config.License = {
    ["A"] = "motorcycle",
    ["B"] = "driver",
    ["C"] = "truck",
    ["D"] = "bus"
}

Config.Blip = {
    enabled = true,
    sprite = 498,
    display = 4,
    scale = 0.7,
    color = 47,
    shortRange = true,
    name = 'Driving School'
}

Config.DrivingSchoolPed = {
    model = 'a_m_y_business_03',
    coords = vec4(223.27, 373.58, 106.39, 64.1),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
    target = {
        icon = 'fas fa-book',
        label = 'Start theoretical test',
        distance = 2.5
    }
}

Config.DrivingInstructorPed = {
    model = 's_m_m_security_01',
    coords = vec4(223.68, 374.73, 106.42, 72.2),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
    target = {
        icon = 'fas fa-car',
        distance = 2.5
    }
}

Config.Notify = {
    system = "ox", -- "qb" or "ox"
    messages = {
        -- Payment messages
        payment_success = "You have paid {price} USD",
        insufficient_funds = "You don't have enough cash! You need {price} USD",
        
        -- Theory test messages
        theory_pass = "You have successfully completed the theory test! Now you need to complete the driving lessons.",
        theory_fail = "You failed the theory test.",
        theory_required = "You must first complete the theory test!",
        
        -- License messages
        license_A = "You have obtained a Category A driver's license (motorcycles)",
        license_B = "You have obtained a Category B driver's license (cars)",
        license_C = "You have obtained a Category C driver's license (vans)",
        license_D = "You have obtained a Category D driver's license (buses)",
        
        -- Driving test messages
        test_started = "Driving test started! Follow the yellow markers and obey the speed limits.",
        penalty_limit = "You can only get a maximum of 3 penalty points, otherwise you will fail!",
        speed_limit = "Speed limit in this zone: {limit} {unit}",
        checkpoint_complete = "Checkpoint {current} completed! Proceed to the next one.",
        test_passed = "You have successfully completed the driving test! Penalty points: {points}/3",
        test_passed_final = "You have successfully completed the driving test!",
        test_failed = "You failed the driving test! Too many penalty points: {points}/3",
        test_failed_reason = "Test failed! Reason: {reason}",
        
        -- Vehicle related messages
        vehicle_destroyed = "The test vehicle was destroyed or disappeared! Test terminated.",
        vehicle_abandoned = "You abandoned the test vehicle! Test failed.",
        return_vehicle = "Proceed to the driving school to return the vehicle!",
        
        -- Failure reasons
        penalty_limit_reached = "Too many penalty points",
        vehicle_destroyed = "Vehicle was destroyed",
        vehicle_abandoned = "Vehicle abandoned",
        
        -- Speeding notifications
        speeding_penalty = "You exceeded the speed limit ({limit} {unit})! Penalty point! ({points}/3)",
        speeding_fail = "You exceeded the speed limit ({limit} {unit})! You have reached 3 penalty points. Test failed."
    }
}

Config.LicenseTypes = {
    A = {
        label = "Group A (Motorcycles)",
        price = 1500,
        vehicle = "pcj",
        vehicleLabel = "Motorcycles",
        target = {
            icon = 'fas fa-motorcycle'
        }
    },
    B = {
        label = "Group B (Vehicle)",
        price = 2000,
        vehicle = "blista",
        vehicleLabel = "Vehicle",
        target = {
            icon = 'fas fa-car-side'
        }
    },
    C = {
        label = "Group C (Trucks)",
        price = 3000,
        vehicle = "mule",
        vehicleLabel = "Trucks",
        target = {
            icon = 'fas fa-truck',
        }
    },
    D = {
        label = "Group D (Bus)",
        price = 4000,
        vehicle = "bus",
        vehicleLabel = "Bus",
        target = {
            icon = 'fas fa-bus'
        }
    }
}

Config.StartLocations = {
    vec4(209.15, 375.28, 107.02, 337.87),
    vec4(205.01, 377.29, 107.24, 343.97),
    vec4(204.81, 390.49, 107.22, 170.89),
    vec4(209.21, 389.92, 107.0, 169.47)
}

Config.TestRoutes = {
    {
        {coords = vec3(35.05, 277.53, 109.48), radius = 5.0, speedLimit = 50},
        {coords = vec3(-127.49, 100.97, 70.85), radius = 5.0, speedLimit = 50},
        {coords = vec3(-393.98, 25.98, 46.72), radius = 5.0, speedLimit = 50},
        {coords = vec3(-464.29, -229.05, 35.46), radius = 5.0, speedLimit = 50},
        {coords = vec3(-565.16, -667.11, 32.54), radius = 5.0, speedLimit = 50},
        {coords = vec3(-303.63, -859.65, 31.13), radius = 5.0, speedLimit = 50},
        {coords = vec3(37.14, -795.8, 43.52), radius = 5.0, speedLimit = 50},
        {coords = vec3(110.38, -591.83, 43.34), radius = 5.0, speedLimit = 50},
        {coords = vec3(311.98, -486.7, 42.67), radius = 5.0, speedLimit = 50},
        {coords = vec3(516.35, -179.26, 53.44), radius = 5.0, speedLimit = 50},
        {coords = vec3(680.88, -12.3, 83.54), radius = 5.0, speedLimit = 50},
        {coords = vec3(214.51, 364.95, 105.61), radius = 5.0, speedLimit = 50},
        {coords = vec3(229.73, 386.12, 105.91), radius = 5.0, speedLimit = 50} -- Back to driving school
    },
}

Config.TestQuestions = {
    {
        question = "What is the speed limit in residential areas in California unless otherwise posted?",
        options = {
            "25 MPH",
            "35 MPH",
            "45 MPH",
            "55 MPH"
        },
        correct = "25 MPH"
    },
    {
        question = "When approaching a stop sign, you must:",
        options = {
            "Slow down and proceed if the way is clear",
            "Come to a complete stop and proceed only when safe",
            "Stop only if there are other vehicles",
            "Honk and continue driving"
        },
        correct = "Come to a complete stop and proceed only when safe"
    },
    {
        question = "What should you do when you see a yellow traffic light?",
        options = {
            "Speed up to cross the intersection",
            "Stop immediately",
            "Proceed with caution",
            "Slow down and prepare to stop"
        },
        correct = "Slow down and prepare to stop"
    },
    {
        question = "What is the legal blood alcohol concentration (BAC) limit for drivers aged 21 and over in California?",
        options = {
            "0.08%",
            "0.10%",
            "0.05%",
            "0.00%"
        },
        correct = "0.08%"
    },
    {
        question = "When driving in fog, you should:",
        options = {
            "Use high-beam headlights",
            "Use low-beam headlights",
            "Turn off your headlights",
            "Drive at the same speed as usual"
        },
        correct = "Use low-beam headlights"
    },
    {
        question = "What does a solid yellow line on your side of the road mean?",
        options = {
            "You may pass if it is safe",
            "No passing is allowed",
            "You may pass only during daylight",
            "You may pass only if there is no traffic"
        },
        correct = "No passing is allowed"
    },
    {
        question = "When should you use your horn?",
        options = {
            "To alert other drivers of your presence",
            "To express frustration",
            "To greet other drivers",
            "To signal your intention to turn"
        },
        correct = "To alert other drivers of your presence"
    },
    {
        question = "What is the minimum following distance recommended under ideal conditions?",
        options = {
            "1 second",
            "2 seconds",
            "3 seconds",
            "4 seconds"
        },
        correct = "2 seconds"
    },
    {
        question = "What should you do if your vehicle starts to skid?",
        options = {
            "Brake hard",
            "Steer in the direction of the skid",
            "Accelerate quickly",
            "Turn the steering wheel sharply"
        },
        correct = "Steer in the direction of the skid"
    },
    {
        question = "When are you allowed to make a U-turn in a business district?",
        options = {
            "Only at intersections",
            "Only when no vehicles are approaching",
            "Only where permitted by signs or signals",
            "Anytime it is safe"
        },
        correct = "Only where permitted by signs or signals"
    },
    {
        question = "What should you do if you miss your exit on a freeway?",
        options = {
            "Stop and reverse",
            "Continue to the next exit",
            "Make a U-turn",
            "Back up slowly"
        },
        correct = "Continue to the next exit"
    },
    {
        question = "What is the penalty for a first-time DUI offense in California?",
        options = {
            "A fine only",
            "A fine and license suspension",
            "No penalty",
            "A warning"
        },
        correct = "A fine and license suspension"
    },
    {
        question = "When should you yield to pedestrians?",
        options = {
            "Only at crosswalks",
            "Only when they have a walk signal",
            "Always, even if they are jaywalking",
            "Only during the day"
        },
        correct = "Always, even if they are jaywalking"
    },
    {
        question = "What does a flashing red traffic light mean?",
        options = {
            "Proceed with caution",
            "Stop and proceed when safe",
            "Slow down and yield",
            "Treat it as a stop sign"
        },
        correct = "Treat it as a stop sign"
    },
    {
        question = "What is the speed limit in school zones during school hours?",
        options = {
            "20 MPH",
            "25 MPH",
            "30 MPH",
            "35 MPH"
        },
        correct = "25 MPH"
    },
    {
        question = "When can you drive in a bike lane?",
        options = {
            "To pass another vehicle",
            "To make a right turn within 200 feet",
            "To park your vehicle",
            "To avoid traffic"
        },
        correct = "To make a right turn within 200 feet"
    },
    {
        question = "What should you do if you are involved in a minor collision?",
        options = {
            "Leave the scene immediately",
            "Move your vehicle out of traffic if possible",
            "Wait for the police before doing anything",
            "Confront the other driver"
        },
        correct = "Move your vehicle out of traffic if possible"
    },
    {
        question = "What does a diamond-shaped sign indicate?",
        options = {
            "A school zone",
            "A railroad crossing",
            "A hazard or warning",
            "A recreational area"
        },
        correct = "A hazard or warning"
    },
    {
        question = "When should you use your turn signals?",
        options = {
            "Only when changing lanes",
            "Only when turning",
            "At least 100 feet before turning or changing lanes",
            "Only in heavy traffic"
        },
        correct = "At least 100 feet before turning or changing lanes"
    },
    {
        question = "What is the purpose of rumble strips on the road?",
        options = {
            "To indicate a bike lane",
            "To warn drivers of an upcoming hazard",
            "To mark the edge of the road",
            "To reduce speed limits"
        },
        correct = "To warn drivers of an upcoming hazard"
    },
    {
        question = "What should you do if you see a pedestrian with a white cane?",
        options = {
            "Honk to alert them",
            "Yield the right-of-way",
            "Speed up to pass them",
            "Ignore them"
        },
        correct = "Yield the right-of-way"
    },
    {
        question = "What is the maximum speed limit on California highways unless otherwise posted?",
        options = {
            "55 MPH",
            "65 MPH",
            "70 MPH",
            "75 MPH"
        },
        correct = "65 MPH"
    },
    {
        question = "What does a green arrow traffic signal mean?",
        options = {
            "Proceed with caution",
            "Stop and wait for a green light",
            "Turn in the direction of the arrow after yielding",
            "Turn in the direction of the arrow; you have the right-of-way"
        },
        correct = "Turn in the direction of the arrow; you have the right-of-way"
    },
    {
        question = "What should you do if your accelerator sticks?",
        options = {
            "Shift to neutral and apply the brakes",
            "Turn off the engine",
            "Pump the accelerator pedal",
            "Steer onto the shoulder"
        },
        correct = "Shift to neutral and apply the brakes"
    },
    {
        question = "What is the purpose of a roundabout?",
        options = {
            "To increase traffic speed",
            "To reduce traffic congestion and improve safety",
            "To create a four-way stop",
            "To allow U-turns"
        },
        correct = "To reduce traffic congestion and improve safety"
    },
    {
        question = "What should you do if you see a flashing yellow traffic light?",
        options = {
            "Stop and wait for a green light",
            "Proceed with caution",
            "Speed up to clear the intersection",
            "Treat it as a stop sign"
        },
        correct = "Proceed with caution"
    },
    {
        question = "What is the correct hand signal for a left turn?",
        options = {
            "Left arm extended straight out",
            "Left arm extended upward",
            "Left arm extended downward",
            "Right arm extended straight out"
        },
        correct = "Left arm extended straight out"
    },
    {
        question = "What should you do if you encounter a large animal on the road?",
        options = {
            "Speed up to scare it away",
            "Brake firmly and sound your horn",
            "Swerve to avoid it",
            "Stop and wait for it to move"
        },
        correct = "Brake firmly and sound your horn"
    },
    {
        question = "What is the purpose of a solid white line on the road?",
        options = {
            "To indicate a bike lane",
            "To separate lanes of traffic moving in the same direction",
            "To mark the edge of the road",
            "To indicate a no-passing zone"
        },
        correct = "To separate lanes of traffic moving in the same direction"
    },
    {
        question = "What should you do if you are driving and it starts to hail?",
        options = {
            "Speed up to get out of the hail",
            "Pull over and wait for the hail to stop",
            "Turn on your high beams",
            "Continue driving at the same speed"
        },
        correct = "Pull over and wait for the hail to stop"
    },
    {
        question = "What does a red octagonal sign mean?",
        options = {
            "Yield",
            "Stop",
            "No Entry",
            "Wrong Way"
        },
        correct = "Stop"
    },
    {
        question = "What is the purpose of a shared center turn lane?",
        options = {
            "To pass slower vehicles",
            "To make left turns from either direction",
            "To park your vehicle",
            "To merge into traffic"
        },
        correct = "To make left turns from either direction"
    },
    {
        question = "What should you do if you are driving and your tire blows out?",
        options = {
            "Brake hard",
            "Steer straight and slow down gradually",
            "Accelerate to regain control",
            "Turn the steering wheel sharply"
        },
        correct = "Steer straight and slow down gradually"
    },
    {
        question = "What does a blue and white sign indicate?",
        options = {
            "A school zone",
            "A rest area",
            "A hospital",
            "A parking zone"
        },
        correct = "A rest area"
    },
    {
        question = "What should you do if you are driving and your gas pedal becomes stuck?",
        options = {
            "Shift to neutral and apply the brakes",
            "Turn off the engine",
            "Pump the gas pedal",
            "Steer onto the shoulder"
        },
        correct = "Shift to neutral and apply the brakes"
    },
    {
        question = "What is the purpose of a yellow curb?",
        options = {
            "Loading and unloading passengers or freight",
            "No parking at any time",
            "Short-term parking",
            "Disabled parking only"
        },
        correct = "Loading and unloading passengers or freight"
    },
    {
        question = "What should you do if you are driving and your brakes fail?",
        options = {
            "Shift to a lower gear and pump the brakes",
            "Turn off the engine",
            "Use the parking brake immediately",
            "Steer onto the shoulder"
        },
        correct = "Shift to a lower gear and pump the brakes"
    },
    {
        question = "What does a green traffic light mean?",
        options = {
            "Proceed with caution",
            "Stop and wait for a green arrow",
            "Go if the way is clear",
            "Yield to oncoming traffic"
        },
        correct = "Go if the way is clear"
    },
    {
        question = "What is the purpose of a crosswalk?",
        options = {
            "To indicate a bike lane",
            "To provide a safe place for pedestrians to cross",
            "To mark the edge of the road",
            "To separate lanes of traffic"
        },
        correct = "To provide a safe place for pedestrians to cross"
    },
    {
        question = "What should you do if you are driving and your headlights fail?",
        options = {
            "Continue driving at the same speed",
            "Pull over and stop",
            "Use your high beams",
            "Turn on your hazard lights"
        },
        correct = "Pull over and stop"
    },
    {
        question = "What does a white curb indicate?",
        options = {
            "Loading and unloading passengers or freight",
            "No parking at any time",
            "Short-term parking",
            "Disabled parking only"
        },
        correct = "Short-term parking"
    },
    {
        question = "What should you do if you are driving and your windshield wipers fail?",
        options = {
            "Continue driving at the same speed",
            "Pull over and stop",
            "Use your high beams",
            "Turn on your hazard lights"
        },
        correct = "Pull over and stop"
    },
    {
        question = "What does a red traffic light mean?",
        options = {
            "Proceed with caution",
            "Stop and wait for a green light",
            "Yield to oncoming traffic",
            "Turn right if the way is clear"
        },
        correct = "Stop and wait for a green light"
    },
    {
        question = "What is the purpose of a yellow curb?",
        options = {
            "Loading and unloading passengers or freight",
            "No parking at any time",
            "Short-term parking",
            "Disabled parking only"
        },
        correct = "Loading and unloading passengers or freight"
    },
    {
        question = "What should you do if you are driving and your engine overheats?",
        options = {
            "Continue driving at the same speed",
            "Pull over and stop",
            "Turn on your high beams",
            "Turn on your hazard lights"
        },
        correct = "Pull over and stop"
    },
    {
        question = "What does a flashing yellow arrow mean?",
        options = {
            "Proceed with caution",
            "Stop and wait for a green arrow",
            "Yield to oncoming traffic",
            "Turn in the direction of the arrow after yielding"
        },
        correct = "Turn in the direction of the arrow after yielding"
    },
    {
        question = "What is the purpose of a solid yellow line on the road?",
        options = {
            "To indicate a bike lane",
            "To separate lanes of traffic moving in opposite directions",
            "To mark the edge of the road",
            "To indicate a no-passing zone"
        },
        correct = "To separate lanes of traffic moving in opposite directions"
    },
    {
        question = "What should you do if you are driving and your steering fails?",
        options = {
            "Brake hard",
            "Shift to neutral and apply the brakes",
            "Accelerate to regain control",
            "Turn the steering wheel sharply"
        },
        correct = "Shift to neutral and apply the brakes"
    }
}

