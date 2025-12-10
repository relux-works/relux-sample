import Foundation

public enum JSONFixtures {
    public static func load(_ filename: String, bundle: Bundle) -> Data {
        guard let url = bundle.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Missing fixture: \(filename).json")
        }
        return data
    }
    
    public static func decode<T: Decodable>(_ filename: String, bundle: Bundle) -> T {
        let data = load(filename, bundle: bundle)
        return try! JSONDecoder().decode(T.self, from: data)
    }
}
