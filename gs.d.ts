/// <reference types="emscripten" />

declare module '@zfanta/ghostscript-wasm' {
  import FileSystemType = Emscripten.FileSystemType

  type Incoming = Partial<Pick<EmscriptenModule, 'noInitialRun'|'locateFile'|'preRun'|'instantiateWasm'>> & {
    noFSInit?: boolean
  }

  interface Exported extends EmscriptenModule {
    FS: typeof FS
    NODEFS: FileSystemType
    WORKERFS:  FileSystemType
    callMain: (args: string[]) => number
  }

  interface GhostscriptModule {
    (moduleOverrides?: Incoming): Promise<Exported>
  }

  const module: GhostscriptModule
  export default module
}
