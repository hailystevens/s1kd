import { Alert, Box, List, ListItem, ListItemText, Typography } from '@mui/material'
import type { AstNode } from '../types'

type Renderer = (node: AstNode, children: React.ReactNode) => React.ReactNode

const registry: Record<string, Renderer> = {
  dmTitle: (_, children) => <Typography variant="h5">{children}</Typography>,
  techName: (_, children) => <Typography variant="h6">{children}</Typography>,
  infoName: (_, children) => <Typography variant="body1">{children}</Typography>,
  para: (_, children) => <Typography paragraph>{children}</Typography>,
  simplePara: (_, children) => <Typography paragraph>{children}</Typography>,
  randomList: (_, children) => <List dense>{children}</List>,
  listItem: (_, children) => (
    <ListItem disablePadding>
      <ListItemText primary={children} />
    </ListItem>
  )
}

function renderNode(node: AstNode): React.ReactNode {
  if (node.type === 'text') {
    return node.text
  }

  if (node.type === 'unsupported') {
    return (
      <Alert severity="warning" sx={{ my: 1 }}>
        Unsupported element: {node.name} ({node.xpath})
      </Alert>
    )
  }

  const children = node.children.map((child, index) => <Box key={`${child.xpath}-${index}`}>{renderNode(child)}</Box>)

  const entry = registry[node.name]
  if (entry) {
    return <>{entry(node, children)}</>
  }

  if (node.type === 'document') {
    return <>{children}</>
  }

  return <Box>{children}</Box>
}

export function AstRenderer({ node }: { node: AstNode }) {
  return <Box>{renderNode(node)}</Box>
}
