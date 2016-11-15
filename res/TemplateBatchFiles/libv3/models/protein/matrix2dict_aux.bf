LoadFunctionLibrary ("../protein.bf");
LoadFunctionLibrary("../../UtilityFunctions.bf");

function mapMatrixToDict (letters, matrix) {
    dict   = {};
    dim    = utility.Array1D (letters);

    for (l1 = 0; l1 < dim - 1; l1 += 1) {
        dict[letters[l1]] = {};
        for (l2 = l1 + 1; l2 < dim; l2 += 1) {
            (dict[letters[l1]])[letters[l2]] = matrix [l1][l2];
        }
    }
    return dict;
}

models.protein.WAG.empirical_Q = {
    {0, 3.26324, 2.34804, 5.02923, 0.668808, 4.50138, 1.00707, 0.6142879999999999, 2.8795, 1.26431, 2.83893, 1.61995, 4.57074, 2.88691, 1.75252, 10.7101, 6.73946, 6.37375, 0.35946, 0.764894}
    {3.26324, 0, 0.0962568, 0.06784229999999999, 1.26464, 0.974403, 0.791065, 0.540574, 0.23523, 1.22101, 1.24069, 0.842805, 0.347612, 0.313977, 1.67824, 4.4726, 1.62992, 3.18413, 2.27837, 1.72794}
    {2.34804, 0.0962568, 0, 19.6173, 0.148478, 2.75024, 2.95706, 0.125304, 1.52466, 0.269452, 0.32966, 17.251, 1.34714, 1.95972, 0.468033, 3.40533, 1.19107, 0.484018, 0.412312, 1.03489}
    {5.02923, 0.06784229999999999, 19.6173, 0, 0.257789, 1.80382, 1.81116, 0.404776, 8.21158, 0.490144, 1.00125, 3.00956, 2.16806, 17.3783, 1.39535, 2.23982, 2.61419, 1.87059, 0.497433, 0.623719}
    {0.668808, 1.26464, 0.148478, 0.257789, 0, 0.158647, 2.15858, 3.36628, 0.282261, 6.72059, 3.78302, 0.305538, 0.51296, 0.317481, 0.326346, 1.7346, 0.546192, 2.06492, 4.86017, 20.5074}
    {4.50138, 0.974403, 2.75024, 1.80382, 0.158647, 0, 0.792457, 0.0967499, 1.18692, 0.194782, 0.553173, 3.57627, 0.773901, 1.04868, 1.85767, 4.2634, 0.717545, 0.5949449999999999, 1.07071, 0.329184}
    {1.00707, 0.791065, 2.95706, 1.81116, 2.15858, 0.792457, 0, 0.439075, 2.82919, 1.58695, 1.28409, 12.5704, 2.21205, 13.6438, 6.79042, 2.35176, 1.50385, 0.376062, 0.834267, 12.3072}
    {0.6142879999999999, 0.540574, 0.125304, 0.404776, 3.36628, 0.0967499, 0.439075, 0, 1.02892, 10.0752, 13.5273, 1.76099, 0.317506, 0.361952, 0.594093, 1.01497, 4.63305, 24.8508, 0.675128, 1.33502}
    {2.8795, 0.23523, 1.52466, 8.21158, 0.282261, 1.18692, 2.82919, 1.02892, 0, 0.818336, 2.9685, 9.57014, 1.76944, 12.3754, 17.0032, 3.07289, 4.40689, 0.970464, 0.436898, 0.423423}
    {1.26431, 1.22101, 0.269452, 0.490144, 6.72059, 0.194782, 1.58695, 10.0752, 0.818336, 0, 15.4228, 0.417907, 1.32127, 2.76265, 1.58126, 1.09535, 1.03778, 5.72027, 2.1139, 1.26654}
    {2.83893, 1.24069, 0.32966, 1.00125, 3.78302, 0.553173, 1.28409, 13.5273, 2.9685, 15.4228, 0, 0.629813, 0.544368, 4.9098, 2.17063, 1.5693, 4.81721, 6.54037, 1.63857, 1.36128}
    {1.61995, 0.842805, 17.251, 3.00956, 0.305538, 3.57627, 12.5704, 1.76099, 9.57014, 0.417907, 0.629813, 0, 0.6198360000000001, 4.90465, 2.0187, 12.6274, 6.45016, 0.623538, 0.228503, 3.45058}
    {4.57074, 0.347612, 1.34714, 2.16806, 0.51296, 0.773901, 2.21205, 0.317506, 1.76944, 1.32127, 0.544368, 0.6198360000000001, 0, 2.96563, 2.15896, 5.12592, 2.52719, 1.0005, 0.442935, 0.686449}
    {2.88691, 0.313977, 1.95972, 17.3783, 0.317481, 1.04868, 13.6438, 0.361952, 12.3754, 2.76265, 4.9098, 4.90465, 2.96563, 0, 9.644769999999999, 3.26906, 2.72592, 0.957268, 0.685467, 0.723509}
    {1.75252, 1.67824, 0.468033, 1.39535, 0.326346, 1.85767, 6.79042, 0.594093, 17.0032, 1.58126, 2.17063, 2.0187, 2.15896, 9.644769999999999, 0, 3.88965, 1.76155, 0.800207, 3.69815, 1.21225}
    {10.7101, 4.4726, 3.40533, 2.23982, 1.7346, 4.2634, 2.35176, 1.01497, 3.07289, 1.09535, 1.5693, 12.6274, 5.12592, 3.26906, 3.88965, 0, 13.9104, 0.739488, 1.6641, 2.50053}
    {6.73946, 1.62992, 1.19107, 2.61419, 0.546192, 0.717545, 1.50385, 4.63305, 4.40689, 1.03778, 4.81721, 6.45016, 2.52719, 2.72592, 1.76155, 13.9104, 0, 4.41086, 0.352251, 0.925072}
    {6.37375, 3.18413, 0.484018, 1.87059, 2.06492, 0.5949449999999999, 0.376062, 24.8508, 0.970464, 5.72027, 6.54037, 0.623538, 1.0005, 0.957268, 0.800207, 0.739488, 4.41086, 0, 1.1609, 1}
    {0.35946, 2.27837, 0.412312, 0.497433, 4.86017, 1.07071, 0.834267, 0.675128, 0.436898, 2.1139, 1.63857, 0.228503, 0.442935, 0.685467, 3.69815, 1.6641, 0.352251, 1.1609, 0, 7.8969}
    {0.764894, 1.72794, 1.03489, 0.623719, 20.5074, 0.329184, 12.3072, 1.33502, 0.423423, 1.26654, 1.36128, 3.45058, 0.686449, 0.723509, 1.21225, 2.50053, 0.925072, 1, 7.8969, 0}
};

fprintf (stdout, mapMatrixToDict (models.protein.alphabet, models.protein.WAG.empirical_Q), "\n"):