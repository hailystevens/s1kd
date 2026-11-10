export type AstNode = {
  type: 'document' | 'element' | 'text' | 'unsupported'
  name: string
  text?: string | null
  attributes: Record<string, string>
  children: AstNode[]
  xpath: string
}

export type Diagnostic = {
  severity: 'info' | 'warning' | 'error'
  code: string
  message: string
  xpath?: string | null
}

export type ModuleSummary = {
  module_id: string
  file_name: string
  source_path: string
  root_element?: string | null
  schema_location?: string | null
  issue?: string | null
  title?: string | null
  size_bytes: number
  parsed: boolean
}

export type ModuleDetail = {
  module_id: string
  ast_version: string
  root_element: string
  source_path: string
  schema_location?: string | null
  diagnostics: Diagnostic[]
  ast: AstNode
}
