local console = {}

function console.read()
    return io.stdin:read()
end

function console.readLine()
    return io.stdin:read("l")
end

print("echo: " .. console.readLine())
