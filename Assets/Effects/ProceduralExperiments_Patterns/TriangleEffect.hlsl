void Triangle_float(float2 UV, float Scale, out float Triangle, out float2 TrianglePosition)
{
    #define N Scale
    float2 p = UV;
    p.x *= 0.86602; // sqrt(3)/2: the height of an equilateral triangle with sides of length 1
    
    float isTwo = fmod(floor(p.y * N), 2.0); 
    float isOne = 1.0 - isTwo; //1.0 if odd-numbered rows.
    
    // Tile several squares with xy-coordinates 0~1
    p = p * N;
    p.x += isTwo * 0.5; // 0.5 displacement of even-numbered columns.
    float2 p_index = floor(p); // Square numbers
    float2 p_rect = frac(p);
    p = p_rect; // Coordinates inside the square
    float xSign = sign(p.x - 0.5); // +1.0 for right side of tile, -1.0 for left side
    p.x = abs(0.5 - p.x); // Symmetrical with x=0.5 as the axis.
    float isInTriangle = step(p.x * 2.0 + p.y, 1.0); // 1.0 if inside a triangle
    float isOutTriangle = 1.0 - isInTriangle; // if outside the triangle
    
    // Central triangle
    float w1 = max( p.x * 2.0 + p.y, 1.0 - p.y * 1.5 ); 

    // Upper right (upper left) triangle
    p = float2(0.5, 1.0) - p;
    float w2 = max(p.x * 2.0 + p.y, 1.0 - p.y * 1.5 );
    // triangle gradient
    Triangle = lerp(1.0 - w2, 1.0 - w1, isInTriangle) / 0.6;

    // Position of the triangle
    float2 triangleIndex = p_index + float2(
    isOutTriangle * xSign / 2.0 // Top left part -0.5, top right part +0.5
    + isOne / 2.0, // The triangle in the radix column is 0.5 off to the side, so +0.5.
    0.0
    );

    // Triangle coordinates
    TrianglePosition = triangleIndex / N;
}