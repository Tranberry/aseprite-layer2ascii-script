-- Layers2ASCII
-- This script exports each layer of an image as a text file in ASCII format, 
-- using incremental symbols to represent the pixels in each layer. The output 
-- consists of multiple text files, one for each layer in the image.
----------------------------------------------------------------------
-- by TRBRY (https://github.com/Tranberry)
--
-- Inspired by joshalexjacobs (https://github.com/Joshalexjacobs)
-- (https://github.com/Joshalexjacobs/aseprite-ascii-script)
--
-- Inspired by  Juan Gaspar García  (https://github.com/PKGaspi)
-- (https://github.com/PKGaspi/AsepriteScripts)
----------------------------------------------------------------------
-- Get the active sprite
sprite = app.activeSprite

if sprite then
    -- Set up a table to keep track of unique colors and how they're represented as symbols
    primaryTable = {}
    -- Keep track of how many symbols have been used so far
    symbolsUsed = 0

    -- Loop through each layer in the sprite
    for _, layer in ipairs(sprite.layers) do
        -- Set up a table to store the pixels in the layer
        pixels = {}

        -- Loop through each cel in the layer
        for _, cel in ipairs(layer.cels) do
            -- Loop through each pixel in the cel
            for it in cel.image:pixels() do
                -- Get the current pixel's value
                local pixelValue = it()

                -- Set the pixel to its current value (not sure why this is necessary)
                it(pixelValue)

                -- If the pixel is not transparent
                if pixelValue ~= 0 then
                    -- Add a new unique color to the primary table if it doesn't already exist
                    if primaryTable[tostring(pixelValue)] == nil then
                        primaryTable[tostring(pixelValue)] = {
                            letter = string.char(48 + symbolsUsed)
                        }
                        symbolsUsed = symbolsUsed + 1
                    end
                end

                -- Store the pixel's value and coordinates in the pixels table
                if pixels[it.y + 1] == nil then
                    pixels[it.y + 1] = {}
                end

                pixels[it.y + 1][it.x + 1] = {
                    pixelValue = pixelValue,
                    x = it.x,
                    y = it.y
                }
            end
        end

        -- Write the pixels to a text file
        local path, title = sprite.filename:match("^(.+[/\\])(.-).([^.]*)$")
        local fileName = path .. layer.name

        -- Try to open the file for writing
        file, err = io.open(fileName .. ".txt", "w")

        if file == nil then
            print("error " .. err)
        else
            -- Set the output to the file
            io.output(file)

            -- Loop through each row of pixels
            for y = 1, #pixels, 1 do
                -- Write a double quote to start the row
                io.write('"')

                -- Loop through each pixel in the row
                for x = 1, #pixels[y] do
                    -- If the pixel is transparent, write a space
                    if pixels[y][x].pixelValue == 0 then
                        io.write(" ")
                    -- Otherwise, write the symbol for the pixel's color
                    else
                        io.write(primaryTable[tostring(pixels[y][x].pixelValue)].letter)
                    end
                end

                -- Add a comma to the end of the row, unless it's the last row
                if y ~= #pixels then
                    io.write('",')
                else
                    io.write('"')
                end

                -- Add a newline character to the end of the row
                io.write('\n')
            end

            -- Close the file
            io.close(file)
        end
    end
end
