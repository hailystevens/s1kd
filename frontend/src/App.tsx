import { useMemo, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Alert,
  Box,
  CircularProgress,
  CssBaseline,
  Divider,
  List,
  ListItemButton,
  ListItemText,
  Paper,
  ThemeProvider,
  Toolbar,
  Typography
} from '@mui/material'
import { fetchModule, fetchModules } from './api'
import { AstRenderer } from './components/AstRenderer'
import { appTheme, designTokens } from './theme'
import { SUPPORTED_AST_VERSION } from './constants'
import type { AstNode } from './types'

type PublicationSection = {
  id: string
  label: string
}

const HEADING_NODE_NAMES = new Set(['title', 'dmTitle', 'techName', 'infoName', 'brDecisionPointText'])

function collectText(node: AstNode): string {
  if (node.type === 'text') {
    return node.text?.trim() ?? ''
  }
  return node.children.map((child) => collectText(child)).join(' ').replace(/\s+/g, ' ').trim()
}

function sectionLabel(node: AstNode): string | null {
  for (const child of node.children) {
    if (child.type !== 'element') {
      continue
    }
    if (HEADING_NODE_NAMES.has(child.name)) {
      const text = collectText(child)
      if (text) {
        return text
      }
    }
  }
  return null
}

function collectPublicationSections(node: AstNode): PublicationSection[] {
  const sections: PublicationSection[] = []

  function visit(current: AstNode): void {
    if (current.type === 'element' && current.attributes.id) {
      sections.push({
        id: current.attributes.id,
        label: sectionLabel(current) ?? current.name
      })
    }
    for (const child of current.children) {
      visit(child)
    }
  }

  visit(node)
  return sections
}

function App() {
  const [moduleId, setModuleId] = useState<string | null>(null)
  const modulesQuery = useQuery({ queryKey: ['modules'], queryFn: fetchModules })

  const parseableModules = useMemo(
    () => (modulesQuery.data ?? []).filter((item) => item.parsed),
    [modulesQuery.data]
  )

  const selectedModuleId = moduleId ?? parseableModules[0]?.module_id

  const moduleQuery = useQuery({
    queryKey: ['module', selectedModuleId],
    queryFn: () => fetchModule(selectedModuleId ?? ''),
    enabled: Boolean(selectedModuleId)
  })

  const publicationSections = useMemo(
    () => (moduleQuery.data ? collectPublicationSections(moduleQuery.data.ast) : []),
    [moduleQuery.data]
  )

  return (
    <ThemeProvider theme={appTheme}>
      <CssBaseline />
      <Box sx={{ display: 'flex', minHeight: '100vh' }}>
        <Paper square sx={{ width: designTokens.spacing.navWidth, borderRight: '1px solid', borderColor: 'divider' }}>
          <Toolbar>
            <Typography variant="h6">S1000D Modules</Typography>
          </Toolbar>
          <Divider />
          {modulesQuery.isLoading ? (
            <Box sx={{ p: 2 }}><CircularProgress size={24} /></Box>
          ) : null}
          {modulesQuery.isError ? (
            <Alert severity="error" sx={{ m: 2 }}>Failed to load module inventory.</Alert>
          ) : null}
          {!modulesQuery.isLoading && parseableModules.length === 0 ? (
            <Alert severity="warning" sx={{ m: 2 }}>No parseable modules discovered.</Alert>
          ) : null}
          <List role="navigation" aria-label="Module navigation">
            {parseableModules.map((item) => (
              <ListItemButton
                key={item.module_id}
                selected={selectedModuleId === item.module_id}
                onClick={() => setModuleId(item.module_id)}
              >
                <ListItemText primary={item.title ?? item.file_name} secondary={item.module_id} />
              </ListItemButton>
            ))}
          </List>
        </Paper>

        <Box component="main" sx={{ flex: 1, p: 3 }}>
          <Typography variant="h4" gutterBottom>
            Interactive Electronic Technical Manual
          </Typography>

          {moduleQuery.isLoading ? <CircularProgress size={28} /> : null}
          {moduleQuery.isError ? <Alert severity="error">Failed to load selected module.</Alert> : null}

          {moduleQuery.data && moduleQuery.data.ast_version !== SUPPORTED_AST_VERSION ? (
            <Alert severity="error">
              Unsupported AST version {moduleQuery.data.ast_version}. Expected {SUPPORTED_AST_VERSION}.
            </Alert>
          ) : null}

          {moduleQuery.data && moduleQuery.data.ast_version === SUPPORTED_AST_VERSION ? (
            <Box>
              <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                AST version {moduleQuery.data.ast_version} · {moduleQuery.data.module_id}
              </Typography>
              {publicationSections.length > 0 ? (
                <Paper variant="outlined" sx={{ mb: 2 }}>
                  <Typography variant="subtitle2" sx={{ px: 2, pt: 1 }}>
                    Publication navigation
                  </Typography>
                  <List dense role="navigation" aria-label="Publication navigation">
                    {publicationSections.map((section) => (
                      <ListItemButton component="a" href={`#${section.id}`} key={section.id}>
                        <ListItemText primary={section.label} secondary={section.id} />
                      </ListItemButton>
                    ))}
                  </List>
                </Paper>
              ) : null}
              {moduleQuery.data.diagnostics.map((diag) => (
                <Alert
                  key={`${diag.code}-${diag.xpath ?? 'root'}`}
                  severity={diag.severity === 'error' ? 'error' : 'warning'}
                  sx={{ mb: 1 }}
                >
                  {diag.message}
                </Alert>
              ))}
              <AstRenderer node={moduleQuery.data.ast} />
            </Box>
          ) : null}
        </Box>
      </Box>
    </ThemeProvider>
  )
}

export default App
