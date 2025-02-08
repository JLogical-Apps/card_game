T closestToZero<T extends num>(T a, T b) => a.abs() < b.abs() ? a : b;
