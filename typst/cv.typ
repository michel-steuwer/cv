#let mainfont = "Valkyrie OT B"
#let sansfont = "Concourse OT 3"
#let accent   = rgb(11, 52, 95)
#let bright   = rgb(255,255,255)
#let gray     = rgb(79, 89, 97)
#let pageHeight   = 29.7cm
#let pageWidth    = 21cm
#let sidebar      = pageWidth/3
#let leftMargin   = 0.25cm
#let rightMargin  = 2cm;
#let topMargin    = 2.5cm;
#let bottomMargin = 3cm;

#let fa(name) = {
  text(
    font: "Font Awesome 6 Free",
    size: 9pt,
    box(name)
  )
}

#let fa-solid(name) = {
  text(
    font: "Font Awesome 6 Free Solid",
    size: 10pt,
    box(name)
  )
}

#let fa-brands(name) = {
  text(
    font: "Font Awesome 6 Brands",
    size: 10pt,
    box(name)
  )
}

#let envelope = symbol(
  "\u{f0e0}",
  ("open", "\u{f2b6}"),
  ("open.text", "\u{f658}"),
  ("square", "\u{f199}"),
)

// #let circle = f111

#let entry(date: none, body) = {
  move(dx: -(2cm + 2*leftMargin),
      grid(
        columns: (2cm, 2*leftMargin, 100%),
        align(right + top, text(fill: bright, number-width: "tabular", date)),
        none,
        body
      )
    )
}

#let small(body) = text(size: 0.9em, body)

#let hl(body) = text(fill: accent, body)

#let cv(
  name: "Name",
  title: none,
  address: (),
  email: none,
  doc
) = {
  set document(
    author: name,
    title: title + name + " - Resume"
  )
 
  set page(
    paper: "a4",
    margin: (
      left: sidebar + leftMargin,
      right: rightMargin,
      top: topMargin,
      bottom: bottomMargin
    ),

    footer:grid(
      columns: (100%-(1/2 * sidebar), (1/2 * sidebar)),
      {
        set align(center)
        [Last updated on ]
      },
      {
        set align(right)
        [Page #counter(page).display("1 of 1",both: true)]
      }
    ),

    background: {
      set align(left)
      block(
        width: sidebar,
        height: pageHeight,
        fill: accent,
        move(dx: -1cm, dy: pageHeight - 4.05cm, // generalize ...
          rotate(-90deg,
            text(
              fill: bright,
              font: sansfont,
              size: 48pt,
              box(width: pageHeight, align(center, smallcaps(name))))
          )
        )
      )
    }
  )

  grid(
    columns: (65%, 35%),
    text(
      fill: accent,
      font: sansfont,
      size: 34pt,
      weight: "bold",
      style(styles => {
        let titleSize = measure(title, styles)
        move(dx: -(titleSize.width + leftMargin + .125em),
          box(width: 100% + titleSize.width)[
            #text(fill: bright, title) #name])
      })
    ),
    {
      set align(right)
      text(
        fill: gray,
        font: sansfont,
        number-type: "old-style",
        number-width: "tabular")[
          #address.join("\n") \
          #box(width: 200%, [#fa[#envelope] #email])
        ]
    }
  )
  
  set text(
    font: mainfont,
    number-type: "old-style",
    size: 11pt
  )

  set par(
    justify: true,
    leading: 0.78em
  )

  show heading.where(
    level: 1
  ): it => {
    set text(
      size: 14.4pt,
      fill: accent,
      font: sansfont,
      weight: "regular",
    )
    move(dx: -(2cm + 2*leftMargin),
      grid(
        columns: (2cm, 2*leftMargin, 100%),
        align(right + horizon, block(fill: bright, width: 2cm, height: 0.3em)),
        none,
        it
      )
    )
    v(.5em)
  }

  show heading.where(
    level: 2
  ): it => {
    set text(
      size: 12pt,
      fill: accent,
      font: sansfont,
      weight: "regular",
    )
    it
    v(.5em)
  }

  show strong: set text(fill: accent)

  set list(
    marker: (move(dy: .5em - 0.11cm, circle(radius: 0.07cm, stroke: accent))),
    spacing: 1.5em
  )

  show list: it => {
    it
    v(1em)
  }

  doc
}