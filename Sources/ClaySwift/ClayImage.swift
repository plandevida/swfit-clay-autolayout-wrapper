import CSDL3
import Foundation

// MARK: - ClayImage

public final class ClayImage {
    private let texture: UnsafeMutablePointer<SDL_Texture>
    public let width: Int32
    public let height: Int32

    public var texturePtr: UnsafeMutableRawPointer {
        UnsafeMutableRawPointer(texture)
    }

    private init(texture: UnsafeMutablePointer<SDL_Texture>, width: Int32, height: Int32) {
        self.texture = texture
        self.width = width
        self.height = height
    }

    deinit {
        SDL_DestroyTexture(texture)
    }

    public convenience init?(path: String, renderer: OpaquePointer) {
        guard let surface = IMG_Load(path) else {
            print("[ClayImage] Failed to load '\(path)': \(String(cString: SDL_GetError()))")
            return nil
        }
        defer { SDL_DestroySurface(surface) }

        guard let texture = SDL_CreateTextureFromSurface(renderer, surface) else {
            print("[ClayImage] Failed to create texture from '\(path)': \(String(cString: SDL_GetError()))")
            return nil
        }

        self.init(texture: texture, width: surface.pointee.w, height: surface.pointee.h)
    }

    public convenience init?(data: Data, renderer: OpaquePointer) {
        var surface: UnsafeMutablePointer<SDL_Surface>?
        data.withUnsafeBytes { ptr in
            guard let base = ptr.baseAddress else { return }
            guard let rwops = SDL_IOFromConstMem(base, data.count) else { return }
            surface = IMG_Load_IO(rwops, false)
        }

        guard let surf = surface else {
            print("[ClayImage] Failed to load from data: \(String(cString: SDL_GetError()))")
            return nil
        }
        defer { SDL_DestroySurface(surf) }

        guard let texture = SDL_CreateTextureFromSurface(renderer, surf) else {
            print("[ClayImage] Failed to create texture from data: \(String(cString: SDL_GetError()))")
            return nil
        }

        self.init(texture: texture, width: surf.pointee.w, height: surf.pointee.h)
    }
}
