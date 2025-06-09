# Markdown extensions

## Math
[MathJax](https://squidfunk.github.io/mkdocs-material/reference/math/)

The following is an example of block syntax:
=== "Example"
    
    $$
    \cos x=\sum_{k=0}^{\infty}\frac{(-1)^k}{(2k)!}x^{2k}
    $$

=== "Content"
    ```
    $$
    \cos x=\sum_{k=0}^{\infty}\frac{(-1)^k}{(2k)!}x^{2k}
    $$
    ```

The following is an example of inline block syntax:
=== "Example"
    
    $\cos x=\sum_{k=0}^{\infty}\frac{(-1)^k}{(2k)!}x^{2k}$

=== "Content"
    ```
    $\cos x=\sum_{k=0}^{\infty}\frac{(-1)^k}{(2k)!}x^{2k}$
    ```

## Diagrams
[D2 documentation](https://d2lang.com/)

??? example "D2 diagram"

    The following is and example of D2 code embedded in markdown:
    ````markdown
    ```d2 pad="10" scale="0.7"
    shape: sequence_diagram
    Client -> Server: Request
    Server."Server thinks about it"
    Client <- Server: Response
    ```
    ````
    
```d2 pad="10" scale="0.7"
shape: sequence_diagram
Client -> Server: Request
Server."Server thinks about it"
Client <- Server: Response
```