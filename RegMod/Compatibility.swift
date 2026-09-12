import Foundation

/// Compatibility layer for class names observed in the original Mach-O.
/// It intentionally performs no unsafe process injection or filesystem assumptions.
final class BinaryPatcher {
    enum PatchError: LocalizedError { case invalidInput, unsupported
        var errorDescription: String? { "This reconstructed build cannot safely patch an unknown binary format." }
    }

    func patch(data: Data, completion: @escaping (Result<Data, Error>) -> Void) {
        guard !data.isEmpty else { completion(.failure(PatchError.invalidInput)); return }
        completion(.failure(PatchError.unsupported))
    }
}

final class GameInjector {
    enum InjectorError: LocalizedError { case unavailable
        var errorDescription: String? { "Direct game-container injection is unavailable in the reconstructed build." }
    }

    func exportShader(_ data: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        completion(.failure(InjectorError.unavailable))
    }
}
