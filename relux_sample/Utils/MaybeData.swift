// Bridge app target to shared NotesModels definition to avoid duplicate generic.
import NotesModels

public typealias MaybeData<T, E> = NotesModels.MaybeData<T, E> where E: Error, T: Sendable
