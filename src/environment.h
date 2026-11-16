// The world's luminance distribution over an equirectangular map of halves, in cells of scale x scale texels, at
// most 1024 a row
// cells[y / scale][x / scale] = sum over its texels (x, y) of LUMINANCE * sine
// LUMINANCE = 0.299 * r + 0.587 * g + 0.114 * b, sine = sin(PI * (y + 0.5) / height)
// Per cell (x, y): rows[y] = sum over x of cells[y][x], total = sum over y of rows[y]
// => data[y][x] = (sum over x' <= x of cells[y][x'] / rows[y], cells[y][x] / rows[y])
// => data[y][w] = (sum over y' <= y of rows[y'] / total, rows[y] / total)
// Sums in double in texel order, each value then a float; a sum of 0 taken as 1, so an empty row reads 0
#pragma once
#include <cmath>
#include <vector>

struct LuminanceCDF {
    unsigned width, height, scale = (width + 1023) / 1024, w = (width + scale - 1) / scale,
        h = (height + scale - 1) / scale;
    std::vector<double> cells = std::vector<double>(size_t(w) * h);
    void add(const float4* rows, unsigned first, unsigned count) { // The map's rows from first on
        for (unsigned y = first; y < first + count; ++y) {
            const double sine = std::sin(M_PI * (y + 0.5) / height);
            for (unsigned x = 0; x < width; ++x) {
                const float4 a = rows[size_t(y - first) * width + x];
                double& cell = cells[size_t(y / scale) * w + x / scale];
                cell = cell + (0.299 * double(_Float16(a.x)) + 0.587 * double(_Float16(a.y)) + 0.114 * double(
                    _Float16(a.z))) * sine;
            }
        }
    }
    std::vector<float2> finish() const { // (w + 1) x h, its last column the marginal
        const auto or1 = [](double value) { return value != 0 ? value : 1; };
        std::vector<double> rows(h);
        double total = 0;
        for (unsigned y = 0; y < h; ++y) {
            for (unsigned x = 0; x < w; ++x) rows[y] = rows[y] + cells[size_t(y) * w + x];
            total = total + rows[y];
        }
        total = or1(total);
        std::vector<float2> data(size_t(w + 1) * h);
        double row = 0;
        for (unsigned y = 0; y < h; ++y) {
            const double mass = or1(rows[y]);
            double cell = 0;
            for (unsigned x = 0; x < w; ++x)
                cell += cells[size_t(y) * w + x], data[size_t(y) * (w + 1) + x] = {float(cell / mass),
                    float(cells[size_t(y) * w + x] / mass)};
            row += rows[y], data[size_t(y) * (w + 1) + w] = {float(row / total), float(rows[y] / total)};
        }
        return data;
    }
};
