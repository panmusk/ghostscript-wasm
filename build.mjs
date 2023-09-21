import { Docker } from 'docker-cli-js'
import { rm } from 'fs/promises'

await rm('./dist', { recursive: true, force: true })

const options = {
  machineName: null, // uses local docker
  currentWorkingDirectory: null, // uses current working directory
  echo: true, // echo command output to stdout/stderr
}

const docker = new Docker(options)

await docker.command('build -t gs .')
const id = (await docker.command('create gs')).raw.trim()
await docker.command(`cp ${id}:/dist .`)
await docker.command(`rm ${id}`)
