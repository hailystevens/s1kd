import { Alert, Box, Link, List, ListItem, ListItemText, Typography } from '@mui/material'
import type { AstNode } from '../types'

type Renderer = (node: AstNode, children: React.ReactNode) => React.ReactNode

function normalizeFragment(value: string | undefined): string | null {
  if (!value) {
    return null
  }
  return value.startsWith('#') ? value.slice(1) : value
}

function withAnchor(node: AstNode, content: React.ReactNode): React.ReactNode {
  return node.attributes.id ? <Box id={node.attributes.id}>{content}</Box> : content
}

const registry: Record<string, Renderer> = {
  title: (_, children) => <Typography variant="h6">{children}</Typography>,
  dmTitle: (_, children) => <Typography variant="h5">{children}</Typography>,
  techName: (_, children) => <Typography variant="h6">{children}</Typography>,
  infoName: (_, children) => <Typography variant="body1">{children}</Typography>,
  para: (_, children) => <Typography paragraph>{children}</Typography>,
  simplePara: (_, children) => <Typography paragraph>{children}</Typography>,
  brPara: (node, children) => withAnchor(node, <Typography paragraph>{children}</Typography>),
  objectUse: (_, children) => <Typography paragraph>{children}</Typography>,
  objectPath: (_, children) => <Typography variant="body2" color="text.secondary">{children}</Typography>,
  objectValue: (_, children) => <Typography variant="body2" component="span">{children}</Typography>,
  brDecisionPointText: (_, children) => <Typography paragraph>{children}</Typography>,
  brDecisionPointValue: (_, children) => <Typography variant="body2">{children}</Typography>,
  brCategory: (_, children) => <Typography variant="subtitle2">{children}</Typography>,
  brCategoryDescription: (_, children) => <Typography paragraph>{children}</Typography>,
  notePara: (_, children) => <Typography variant="body2">{children}</Typography>,
  emphasis: (_, children) => <Typography component="em">{children}</Typography>,
  randomList: (_, children) => <List dense>{children}</List>,
  listItem: (_, children) => (
    <ListItem disablePadding>
      <ListItemText primary={children} />
    </ListItem>
  ),
  internalRef: (node, children) => {
    const targetId = normalizeFragment(node.attributes.internalRefId)
    if (!targetId) {
      return <>{children}</>
    }
    return <Link href={`#${targetId}`}>{children}</Link>
  },
  dmRef: (node, children) => {
    const targetId = normalizeFragment(node.attributes.referredFragment)
    if (!targetId) {
      return <>{children}</>
    }
    return <Link href={`#${targetId}`}>{children}</Link>
  }
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

  return withAnchor(node, <Box>{children}</Box>)
}

export function AstRenderer({ node }: { node: AstNode }) {
  return <Box>{renderNode(node)}</Box>
}
