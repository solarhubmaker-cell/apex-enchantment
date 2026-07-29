local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local Title = Instance.new("TextLabel", MainFrame)
local ScrollingFrame = Instance.new("ScrollingFrame", MainFrame)
local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)

MainFrame.Name = "ApexHub"
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "Apex Enchantment"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold

ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
ScrollingFrame.ScrollBarThickness = 2

UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateToggleButton(name)
    local Button = Instance.new("TextButton", ScrollingFrame)
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.Text = name .. ": OFF"
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14

    Button.MouseButton1Click:Connect(function()
        if Button.Text == name .. ": OFF" then
            Button.Text = name .. ": ON"
            Button.TextColor3 = Color3.new(0,1,0)
        else
            Button.Text = name .. ": OFF"
            Button.TextColor3 = Color3.new(1,1,1)
        end
    end)
end

CreateToggleButton("Aimlock")
CreateToggleButton("Player ESP")
CreateToggleButton("Silent Aim")
CreateToggleButton("Speed Hack")

local SpeedBtn = Instance.new("TextButton", ScrollingFrame)
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 35)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBtn.Text = "Set Speed: 100"
SpeedBtn.TextColor3 = Color3.new(1,1,1)
SpeedBtn.Font = Enum.Font.Gotham
SpeedBtn.TextSize = 14                                            "name": "Code",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/ui/Code.lua"
                                            ]
                                        },
                                        {
                                            "name": "Dropdown",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/ui/Dropdown.lua"
                                            ]
                                        },
                                        {
                                            "name": "Input",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/ui/Input.lua"
                                            ]
                                        },
                                        {
                                            "name": "Label",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/ui/Label.lua"
                                            ]
                                        },
                                        {
                                            "name": "ScrollSlider",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/ui/ScrollSlider.lua"
                                            ]
                                        },
                                        {
                                            "name": "Tag",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/ui/Tag.lua"
                                            ]
                                        },
                                        {
                                            "name": "Toggle",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/ui/Toggle.lua"
                                            ]
                                        },
                                        {
                                            "name": "Tooltip",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/ui/Tooltip.lua"
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "name": "window",
                                    "className": "ModuleScript",
                                    "filePaths": [
                                        "src/components/window/init.lua"
                                    ],
                                    "children": [
                                        {
                                            "name": "Dialog",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/window/Dialog.lua"
                                            ]
                                        },
                                        {
                                            "name": "Element",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/window/Element.lua"
                                            ]
                                        },
                                        {
                                            "name": "Init",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/window/Init.lua"
                                            ]
                                        },
                                        {
                                            "name": "Openbutton",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/window/Openbutton.lua"
                                            ]
                                        },
                                        {
                                            "name": "Section",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/window/Section.lua"
                                            ]
                                        },
                                        {
                                            "name": "Tab",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/components/window/Tab.lua"
                                            ]
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "name": "config",
                            "className": "ModuleScript",
                            "filePaths": ["src/config/init.lua"],
                            "children": [
                                {
                                    "name": "Init",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/config/Init.lua"]
                                }
                            ]
                        },
                        {
                            "name": "elements",
                            "className": "ModuleScript",
                            "filePaths": ["src/elements/init.lua"],
                            "children": [
                                {
                                    "name": "Button",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Button.lua"]
                                },
                                {
                                    "name": "Code",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Code.lua"]
                                },
                                {
                                    "name": "Colorpicker",
                                    "className": "ModuleScript",
                                    "filePaths": [
                                        "src/elements/Colorpicker.lua"
                                    ]
                                },
                                {
                                    "name": "Divider",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Divider.lua"]
                                },
                                {
                                    "name": "Dropdown",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Dropdown.lua"]
                                },
                                {
                                    "name": "Group",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Group.lua"]
                                },
                                {
                                    "name": "HStack",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/HStack.lua"]
                                },
                                {
                                    "name": "Image",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Image.lua"]
                                },
                                {
                                    "name": "Init",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Init.lua"]
                                },
                                {
                                    "name": "Input",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Input.lua"]
                                },
                                {
                                    "name": "Keybind",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Keybind.lua"]
                                },
                                {
                                    "name": "Paragraph",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Paragraph.lua"]
                                },
                                {
                                    "name": "ProgressBar",
                                    "className": "ModuleScript",
                                    "filePaths": [
                                        "src/elements/ProgressBar.lua"
                                    ]
                                },
                                {
                                    "name": "Section",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Section.lua"]
                                },
                                {
                                    "name": "Slider",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Slider.lua"]
                                },
                                {
                                    "name": "Space",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Space.lua"]
                                },
                                {
                                    "name": "Toggle",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Toggle.lua"]
                                },
                                {
                                    "name": "VStack",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/VStack.lua"]
                                },
                                {
                                    "name": "Video",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Video.lua"]
                                },
                                {
                                    "name": "Viewport",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/elements/Viewport.lua"]
                                }
                            ]
                        },
                        {
                            "name": "modules",
                            "className": "Folder",
                            "children": [
                                {
                                    "name": "Creator",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/modules/Creator.lua"]
                                },
                                {
                                    "name": "DynamicShape",
                                    "className": "ModuleScript",
                                    "filePaths": [
                                        "src/modules/DynamicShape.lua"
                                    ]
                                },
                                {
                                    "name": "Highlighter",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/modules/Highlighter.lua"]
                                },
                                {
                                    "name": "Icons",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/modules/Icons.lua"]
                                },
                                {
                                    "name": "Localization",
                                    "className": "ModuleScript",
                                    "filePaths": [
                                        "src/modules/Localization.lua"
                                    ]
                                }
                            ]
                        },
                        {
                            "name": "server",
                            "className": "Folder",
                            "children": [
                                {
                                    "name": "Discord",
                                    "className": "Script",
                                    "filePaths": [
                                        "src/server/Discord.server.lua"
                                    ]
                                },
                                {
                                    "name": "Icons",
                                    "className": "Script",
                                    "filePaths": ["src/server/Icons.server.lua"]
                                },
                                {
                                    "name": "PullRequest",
                                    "className": "Script",
                                    "filePaths": [
                                        "src/server/PullRequest.server.lua"
                                    ]
                                }
                            ]
                        },
                        {
                            "name": "themes",
                            "className": "ModuleScript",
                            "filePaths": ["src/themes/init.lua"],
                            "children": [
                                {
                                    "name": "Fallbacks",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/themes/Fallbacks.lua"]
                                },
                                {
                                    "name": "Init",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/themes/Init.lua"]
                                }
                            ]
                        },
                        {
                            "name": "utils",
                            "className": "Folder",
                            "children": [
                                {
                                    "name": "Acrylic",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/utils/Acrylic/init.lua"],
                                    "children": [
                                        {
                                            "name": "Blur",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/Acrylic/Blur.lua"
                                            ]
                                        },
                                        {
                                            "name": "Init",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/Acrylic/Init.lua"
                                            ]
                                        },
                                        {
                                            "name": "Paint",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/Acrylic/Paint.lua"
                                            ]
                                        },
                                        {
                                            "name": "Utils",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/Acrylic/Utils.lua"
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "name": "services",
                                    "className": "ModuleScript",
                                    "filePaths": [
                                        "src/utils/services/init.lua"
                                    ],
                                    "children": [
                                        {
                                            "name": "Init",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/services/Init.lua"
                                            ]
                                        },
                                        {
                                            "name": "JunkieDevelopment",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/services/JunkieDevelopment.lua"
                                            ]
                                        },
                                        {
                                            "name": "Luarmor",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/services/Luarmor.lua"
                                            ]
                                        },
                                        {
                                            "name": "PandaDevelopment",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/services/PandaDevelopment.lua"
                                            ]
                                        },
                                        {
                                            "name": "Platoboost",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/utils/services/Platoboost.lua"
                                            ]
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            "name": "Icons",
                            "className": "Folder",
                            "children": [
                                {
                                    "name": "Main-v2",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/Icons/Main-v2.lua"]
                                },
                                {
                                    "name": "Main",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/Icons/Main.lua"]
                                },
                                {
                                    "name": "craft",
                                    "className": "Folder",
                                    "children": [
                                        {
                                            "name": "dist",
                                            "className": "Folder",
                                            "children": [
                                                {
                                                    "name": "Icons",
                                                    "className": "ModuleScript",
                                                    "filePaths": [
                                                        "src/Icons/craft/dist/Icons.lua"
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "name": "geist",
                                    "className": "Folder",
                                    "children": [
                                        {
                                            "name": "dist",
                                            "className": "Folder",
                                            "children": [
                                                {
                                                    "name": "Icons",
                                                    "className": "ModuleScript",
                                                    "filePaths": [
                                                        "src/Icons/geist/dist/Icons.lua"
                                                    ]
                                                }
                                            ]
                                        },
                                        {
                                            "name": "pascal2kebab",
                                            "className": "ModuleScript",
                                            "filePaths": [
                                                "src/Icons/geist/pascal2kebab.lua"
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "name": "gravity",
                                    "className": "Folder",
                                    "children": [
                                        {
                                            "name": "dist",
                                            "className": "Folder",
                                            "children": [
                                                {
                                                    "name": "Icons",
                                                    "className": "ModuleScript",
                                                    "filePaths": [
                                                        "src/Icons/gravity/dist/Icons.lua"
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "name": "lucide",
                                    "className": "Folder",
                                    "children": [
                                        {
                                            "name": "dist",
                                            "className": "Folder",
                                            "children": [
                                                {
                                                    "name": "Icons",
                                                    "className": "ModuleScript",
                                                    "filePaths": [
                                                        "src/Icons/lucide/dist/Icons.lua"
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "name": "sfsymbols",
                                    "className": "Folder",
                                    "children": [
                                        {
                                            "name": "dist",
                                            "className": "Folder",
                                            "children": [
                                                {
                                                    "name": "Icons",
                                                    "className": "ModuleScript",
                                                    "filePaths": [
                                                        "src/Icons/sfsymbols/dist/Icons.lua"
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "name": "solar",
                                    "className": "Folder",
                                    "children": [
                                        {
                                            "name": "dist",
                                            "className": "Folder",
                                            "children": [
                                                {
                                                    "name": "Icons",
                                                    "className": "ModuleScript",
                                                    "filePaths": [
                                                        "src/Icons/solar/dist/Icons.lua"
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {
                                    "name": "test",
                                    "className": "ModuleScript",
                                    "filePaths": ["src/Icons/test.lua"]
                                }
                            ]
                        }
                    ]
                },
                {
                    "name": "build",
                    "className": "Folder",
                    "children": [
                        {
                            "name": "darklua.config",
                            "className": "ModuleScript",
                            "filePaths": ["build/darklua.config.json"]
                        },
                        {
                            "name": "darklua.dev.config",
                            "className": "ModuleScript",
                            "filePaths": ["build/darklua.dev.config.json"]
                        },
                        {
                            "name": "header",
                            "className": "ModuleScript",
                            "filePaths": ["build/header.lua"]
                        },
                        {
                            "name": "package",
                            "className": "ModuleScript",
                            "filePaths": ["build/package.lua"]
                        }
                    ]
                }
            ]
        },
        {
            "name": "ServerScriptService",
            "className": "ServerScriptService",
            "children": [
                {
                    "name": "Discord",
                    "className": "Script",
                    "filePaths": ["src/server/Discord.server.lua"]
                },
                {
                    "name": "Icons",
                    "className": "Script",
                    "filePaths": ["src/server/Icons.server.lua"]
                },
                {
                    "name": "PullRequest",
                    "className": "Script",
                    "filePaths": ["src/server/PullRequest.server.lua"]
                }
            ]
        },
        {
            "name": "StarterPlayer",
            "className": "StarterPlayer",
            "children": [
                {
                    "name": "StarterPlayerScripts",
                    "className": "StarterPlayerScripts",
                    "children": [
                        {
                            "name": "main",
                            "className": "LocalScript",
                            "filePaths": ["main.client.lua"]
                        }
                    ]
                }
            ]
        }
    ]
}
