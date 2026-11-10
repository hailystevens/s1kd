import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { AstRenderer } from './AstRenderer'

const node = {
  type: 'document' as const,
  name: 'dmodule',
  attributes: {},
  xpath: '/',
  children: [
    {
      type: 'element' as const,
      name: 'para',
      attributes: {},
      xpath: '/dmodule/para[1]',
      children: [
        {
          type: 'text' as const,
          name: '#text',
          text: 'Rendered text',
          attributes: {},
          xpath: '/dmodule/para[1]/text()[1]',
          children: []
        }
      ]
    }
  ]
}

describe('AstRenderer', () => {
  it('renders paragraph text from AST nodes', () => {
    render(<AstRenderer node={node} />)
    expect(screen.getByText('Rendered text')).toBeInTheDocument()
  })
})
