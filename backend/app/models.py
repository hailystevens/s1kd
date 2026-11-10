from __future__ import annotations

from typing import Literal
from pydantic import BaseModel, Field

AST_VERSION = "1.0.0"


class Diagnostic(BaseModel):
    severity: Literal["info", "warning", "error"]
    code: str
    message: str
    xpath: str | None = None


class AstNode(BaseModel):
    type: Literal["document", "element", "text", "unsupported"]
    name: str
    text: str | None = None
    attributes: dict[str, str] = Field(default_factory=dict)
    children: list["AstNode"] = Field(default_factory=list)
    xpath: str


AstNode.model_rebuild()


class ModuleSummary(BaseModel):
    module_id: str
    file_name: str
    source_path: str
    root_element: str | None = None
    schema_location: str | None = None
    issue: str | None = None
    title: str | None = None
    size_bytes: int
    parsed: bool


class ModuleDetail(BaseModel):
    module_id: str
    ast_version: str
    root_element: str
    source_path: str
    schema_location: str | None = None
    diagnostics: list[Diagnostic] = Field(default_factory=list)
    ast: AstNode
