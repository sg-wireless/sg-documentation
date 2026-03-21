Print
=====

Using ``print()`` statements in your Python script is quite easy. But did you know
you can also concatenate strings and variables inline? If you are familiar with C,
its functionality is similar to the ``printf()`` function, but with ``\n`` always
included.

.. code-block:: python

   import machine

   print("hello world")
   print("hello world.", end='')  # do not end line

   # you can also specify different endings, like additional text, tabs
   # or any other escape characters
   for i in range(0, 9):
       print(".", end='')
   print("\n")  # feed a new line

   print("\t tabbed in")

   # you can specify a variable into the string as well!
   print("hello world: " + str(machine.rng()) + " random number")

   # or use format
   print("hello world: {} {}".format(machine.rng(), " random number"))

   # you can also ask for user input
   result = input("what's up?\n")
   print(result)

   # and lastly, you can also print like this, which is very useful
   # when printing large amounts of data
   i = 10
   print(1, 2, 3, 'e', i)
