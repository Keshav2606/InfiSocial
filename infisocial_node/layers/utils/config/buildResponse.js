function buildResponse(statusCode, body) {
    const responseHeaders = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
    };

    return {
        statusCode,
        headers: responseHeaders,
        body: body ? JSON.stringify(body) : null,
    };
}

function handlePreflight() {
    return buildResponse(200, null);
}

module.exports = { buildResponse, handlePreflight };
